// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/shader-3"
{	//逐顶点漫反射
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
			Tags{"LightMode" = "ForwardBase"} //设置光照模式
			CGPROGRAM
#include "Lighting.cginc" //引用unity内置光照变量
#pragma vertex vert
#pragma fragment frag
			struct a2v {
				float4 vertex:POSITION;
				float3 normal:NORMAL;
			};
			struct v2f {
				float4 position:SV_POSITION;
				fixed3 color : COLOR;
			};
			v2f vert(a2v v) {
				v2f f;
				f.position = UnityObjectToClipPos(v.vertex);//模型空间坐标转剪裁空间坐标

				fixed3 normalDir = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 diffuse = _LightColor0.rgb *  max(0, dot(normalDir, lightDir));

				f.color = diffuse;
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
