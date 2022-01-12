// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/shader-2"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        
    }
    SubShader
    {
		Pass{

			Tags { "LightMode"="ForwardBase" }

			CGPROGRAM
	#include "Lighting.cginc"
	#pragma vertex vert //声明顶点函数
	#pragma fragment frag //声明片元函数
			struct a2v {
				float4 vertex:POSITION; //用模型空间的顶点坐标填充vertex
				float3 normal:NORMAL; //法线方向
			};
			struct v2f {
				float4 position:SV_POSITION; //裁剪空间坐标
				float3 temp:COLOR0;
			};
			v2f vert(a2v v) {
				v2f f;
				f.position = UnityObjectToClipPos(v.vertex);
				f.temp = v.normal;
				return f;
			}
			fixed4 frag(v2f f) : SV_Target{
				return fixed4(f.temp, 1);
			}
			ENDCG

		}
    }
    FallBack "VertexLit"
}
