// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

Shader "Shader Book/Chapter 9/ForwardRendering"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Gloss("Gloss",Range(20,100)) = 50
		_Color("Color",Color) = (1,1,1,1)
    }
    SubShader
    {
		CGINCLUDE //CGINCLUDE 变量和函数在多pass里面复用
		#include "Lighting.cginc"
		#include "AutoLight.cginc"
		half _Gloss;
		fixed4 _Color;

		struct a2v{
			float4 position : POSITION;
			float3 normal:NORMAL;

		};

		struct v2f{
			float4 position : SV_POSITION;
			float4 vertex : COLOR0;
			float3 normal : COLOR1;
		};

		v2f vert(a2v v){
			v2f f;
			f.position = UnityObjectToClipPos(v.position);
			f.vertex = v.position;
			f.normal = v.normal;
			return f;
		}

		fixed4 frag(v2f f) : SV_TARGET {
			fixed3 worldNormal = normalize(UnityObjectToWorldNormal(f.normal));//世界坐标下的单位法线方向

			#ifdef USING_DIRECTIONAL_LIGHT
				fixed3 worldLightDir = normalize(WorldSpaceLightDir(f.vertex));//世界坐标下的单位光源方向
			#else
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz-mul(unity_ObjectToWorld,f.vertex).xyz);//世界坐标下的单位光源方向
			#endif

			fixed3 worldViewDir = normalize(WorldSpaceViewDir(f.vertex));
			fixed3 halfDir = normalize(worldLightDir + worldViewDir);

			

			//DIFFUSE
			fixed3 diffuse = _LightColor0.rgb * max(0,dot(worldNormal,worldLightDir));

			//SPECULAR
			fixed3 specular = _LightColor0.rgb * pow(max(0,dot(worldNormal,halfDir)),_Gloss);

			//ambient
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * 0.1;
			
			//光照衰减
			#ifdef USING_DIRECTIONAL_LIGHT
				fixed atten = 0.9;
			#else //非平行光的衰减，在_LightTexture0纹理上面，按点在光源空间下的坐标进行采样
				float3 lightCoord = mul(unity_WorldToLight,mul(unity_ObjectToWorld,f.vertex)).xyz;
				fixed atten = tex2D(_LightTexture0,dot(lightCoord,lightCoord).rr).UNITY_ATTEN_CHANNEL;
			#endif

			return fixed4(ambient + _Color.rgb*(diffuse + specular)*atten,1.0);
		}
		ENDCG

        Pass
        {//Base pass
			Tags {"LightMode"="ForwardBase"}
			
			CGPROGRAM

			//编译指令，正确获取光照衰减等光照变量
			#pragma multi_compile_fwdbase

			#pragma vertex vert
			#pragma fragment frag

			ENDCG
            
        }

		pass{
			Tags{"LightMode"="ForwardAdd"}
			Blend One One

			CGPROGRAM

			//编译指令，正确获取光照衰减等光照变量
			#pragma multi_compile_fwdadd

			#pragma vertex vert
			#pragma fragment frag

			ENDCG
		}
    }
	Fallback "VertexLit"
}
