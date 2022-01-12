Shader "Custom/shader-7"
{	//逐像素高光反射 + 逐像素漫反射
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
	#include "lighting.cginc"
	#pragma vertex vert
	#pragma fragment frag
				half _Gross;
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			struct v2f {
				float4 position : SV_POSITION;
				float3 normal : COLOR0;
				float4 vertex : COLOR1;
			};
			v2f vert(a2v v) {
				v2f f;
				f.position = UnityObjectToClipPos(v.vertex);
				f.normal = v.normal;
				f.vertex = v.vertex;
				return f;
			}

			fixed4 frag(v2f f) : SV_Target{
				//漫反射
				fixed3 normalDir = normalize(UnityObjectToWorldNormal(f.normal));
				fixed3 lightDir = normalize(WorldSpaceLightDir(f.vertex));
				fixed3 diffuse = _LightColor0.rgb * max(0, dot(normalDir, lightDir));

				//高光反射
				fixed3 reflectDir = normalize(reflect(-lightDir, normalDir));
				fixed3 viewDir = normalize(WorldSpaceViewDir(f.vertex));
				fixed3 specular = _LightColor0.rgb * pow(max(0, dot(reflectDir, viewDir)), _Gross);

				return fixed4(diffuse + specular, 1);
			}

			ENDCG
		}
    }
    FallBack "VertexLit"
}
