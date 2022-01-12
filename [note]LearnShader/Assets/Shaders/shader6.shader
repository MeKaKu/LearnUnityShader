Shader "Custom/shader-6"
{	//逐顶点高光反射 + 逐顶点漫反射
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
		_Gross("Gross",Int) = 10
	}
		SubShader
		{
			Pass{
				Tags{"LightMode" = "ForwardBase"}
				CGPROGRAM
	#include "Lighting.cginc"
	#pragma vertex vert
	#pragma fragment frag
			half _Gross;
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			struct v2f {
				float4 position : SV_POSITION;
				fixed3 diffuse : COLOR0;
				fixed3 specular : COLOR1;
			};
			v2f vert(a2v v) {
				v2f f;
				f.position = UnityObjectToClipPos(v.vertex);
				
				//漫反射
				fixed3 normalDir = normalize(mul(v.normal,(float3x3)unity_ObjectToWorld));
				fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				f.diffuse = _LightColor0.rgb * max(0, dot(normalDir, lightDir));

				//高光反射
				fixed3 reflectDir = normalize(reflect(-lightDir, normalDir));
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex));
				f.specular = _LightColor0.rgb * pow(max(0, dot(viewDir, reflectDir)), _Gross);

				return f;
			}

			fixed4 frag(v2f f) : SV_Target {
				return fixed4(f.diffuse + f.specular, 1);
			}
			ENDCG
		}
    }
    FallBack "VertexLit"
}
