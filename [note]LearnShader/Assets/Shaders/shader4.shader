// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/shader-4"
{ //逐像素漫反射
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
			Tags{ "LightMode" = "ForwardBase" }
			CGPROGRAM
#include "Lighting.cginc"
#pragma vertex vert
#pragma fragment frag
			struct a2v {
				float4 vertex:POSITION;
				float3 normal:NORMAL;
			};
			struct v2f {
				float4 position:SV_POSITION;
				float3 normal:COLOR;
			};
			v2f vert(a2v v) {
				v2f f;
				f.position = UnityObjectToClipPos(v.vertex);
				f.normal = v.normal;
				return f;
			}
			fixed4 frag(v2f f) : SV_Target {
				fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 normalDir = normalize(mul(f.normal, (float3x3)unity_WorldToObject));
				fixed3 color = _LightColor0.rgb * max(0, dot(lightDir, normalDir));
				return fixed4(color, 1);	
			}
			ENDCG
		}

    }
    FallBack "VertexLit"
}
