Shader "Custom/shader-5"
{ //半兰伯特漫反射
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
		Pass{
			Tags{"LightMode" = "ForwardBase"}
			CGPROGRAM
#include "Lighting.cginc"
#pragma vertex vert
#pragma fragment frag
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			struct v2f {
				float4 position : SV_POSITION;
				fixed3 color : COLOR;
			};
			v2f vert(a2v v) {
				v2f f;
				f.position = UnityObjectToClipPos(v.vertex);
				fixed3 normalDir = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				f.color = _LightColor0.rgb * (0.5*dot(normalDir, lightDir) + 0.5);

				return f;
			}
			fixed4 frag(v2f f) :SV_Target{
				return fixed4(f.color,1);
			}
			ENDCG
		}
    }
    FallBack "VertexLit"
}
