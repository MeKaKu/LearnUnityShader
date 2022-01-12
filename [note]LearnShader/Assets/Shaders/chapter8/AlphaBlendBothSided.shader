// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Shader Book/Chapter 8/AlphaBlendBothSided" {
	Properties{
		_Color("Color",Color)=(1,1,1,1) //颜色
		_MainTex("Main Tex",2D)="white"{} //主纹理
		_AlphaScale("Alpha Scale",Range(0,1))=1 //透明度测试的阈值
	}
	SubShader{
		Tags{
			"Queue"="Transparent" //渲染队列
			"IgnoreProjector"="True" //忽略投影
			"RenderType"="Transparent" //指明该Shader是一个使用了透明度混合的Shader
		}

		Pass{
			Tags{
				"LightMode"="ForwardBase" //定义该Pass在Unity的光照流水线中的角色，取得正确的内置光照变量（前向渲染路径）
			}

			Cull Front //剔除面向摄像机的图元(面向摄像机的图元不会被渲染)

			ZWrite Off //关闭深度写入
			Blend SrcAlpha OneMinusSrcAlpha //混合模式 语义 Blend SrcFactor DstFactor
											//DstColor(new) = SrcFactor*SrcColor(片元/透明物体的颜色,) + DstFactor*DstColor(已经存在于缓冲区的颜色)

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _AlphaScale;

			struct a2v{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};
			struct v2f{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
			};

			v2f vert(a2v v){
				v2f f;
				f.pos = UnityObjectToClipPos(v.vertex);
				f.worldNormal = UnityObjectToWorldNormal(v.normal);
				f.worldPos = mul(unity_ObjectToWorld,v.vertex);
				f.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
				return f;
			}

			fixed4 frag(v2f f) : SV_Target {
				float3 worldNormal = normalize(f.worldNormal);
				float3 worldLightDir = normalize(UnityWorldSpaceLightDir(f.worldPos));
				fixed4 texColor = tex2D(_MainTex,f.uv);

				fixed3 albedo = texColor.rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(worldNormal,worldLightDir));

				return fixed4(ambient + diffuse, texColor.a * _AlphaScale);//设置透明通道
			}

			ENDCG

		}

		Pass{
			Tags{
				"LightMode"="ForwardBase" //定义该Pass在Unity的光照流水线中的角色，取得正确的内置光照变量（前向渲染路径）
			}

			ZWrite Off //关闭深度写入
			Blend SrcAlpha OneMinusSrcAlpha //混合模式 语义 Blend SrcFactor DstFactor
											//DstColor(new) = SrcFactor*SrcColor(片元/透明物体的颜色,) + DstFactor*DstColor(已经存在于缓冲区的颜色)

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _AlphaScale;

			struct a2v{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};
			struct v2f{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
			};

			v2f vert(a2v v){
				v2f f;
				f.pos = UnityObjectToClipPos(v.vertex);
				f.worldNormal = UnityObjectToWorldNormal(v.normal);
				f.worldPos = mul(unity_ObjectToWorld,v.vertex);
				f.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
				return f;
			}

			fixed4 frag(v2f f) : SV_Target {
				float3 worldNormal = normalize(f.worldNormal);
				float3 worldLightDir = normalize(UnityWorldSpaceLightDir(f.worldPos));
				fixed4 texColor = tex2D(_MainTex,f.uv);

				fixed3 albedo = texColor.rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(worldNormal,worldLightDir));

				return fixed4(ambient + diffuse, texColor.a * _AlphaScale);//设置透明通道
			}

			ENDCG

		}
		
	}
	FallBack "Transparent/VertexLit"
}