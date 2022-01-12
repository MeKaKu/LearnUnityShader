// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/shader-1" //Shader名字，可以与文件名不一样
{
	Properties{ //属性
		_Color("Color",Color) = (1,1,1,1) //变量名("外显名",类型) = 初始值		 
	}

	Subshader{ //可以有多个Subshader，适配不同性能的显卡（从上往下选择显卡可以渲染的Subshader
		Pass { //必须至少有一个Pass
			CGPROGRAM
			//使用CG编写Shader代码
			//声明顶点函数
			#pragma vertex vert
			//声明片元函数
			#pragma fragment frag
			
			struct a2v {
				float4 vertex:POSITION;//顶点坐标
				float3 normal:NORMAL;//法线方向
				float4 texcoord:TEXCOORD0;//纹理0
			};
			struct v2f {
				float4 vertex: SV_POSITION;//剪裁空间顶点坐标
				float4 temp:COLOR0;
			};
			v2f vert(a2v v) {
				v2f f;
				f.vertex = UnityObjectToClipPos(v.vertex);
				return f;
			}
			fixed4 frag(v2f f) : SV_Target {
				return fixed4(1, 1, 1, 1);
			}
			
			ENDCG
		}
	}

	//默认使用的Shader
	Fallback "VertexLit"
}
