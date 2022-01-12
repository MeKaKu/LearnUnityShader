Shader "Custom/shader-13"
{	//纹理贴图 + 逐像素半兰伯特漫反射
	//+法线映射
	//+凹凸参数
    Properties
    {
		_MainTex("Main Texture",2D) = "white"{}
		_NormalMap("Normal Map",2D) = "bump"{}
		_Gross("Gross",Range(5,30)) = 10
		_BumpScale("Bump Scale",Float) = 1
	}
		SubShader
		{
			Pass{
				Tags{"LightMode" = "ForwardBase"}
				CGPROGRAM
	#include "lighting.cginc"
	#pragma vertex vert
	#pragma fragment frag
			sampler2D _MainTex;
			sampler2D _NormalMap;
			float4 _MainTex_ST;
			float4 _NormalMap_ST;
			half _Gross;
			float _BumpScale;
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT; //切线
				float4 texcoord : TEXCOORD0;
			};
			struct v2f {
				float4 position : SV_POSITION;
				float3 lightDir : COLOR0;
				float4 texcoord : TEXCOORD0;
			};
			v2f vert(a2v v) {
				v2f f;
				f.position = UnityObjectToClipPos(v.vertex);
				f.texcoord.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				f.texcoord.zw = v.texcoord.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;

				TANGENT_SPACE_ROTATION; //得到矩阵rotation (自动用到v.normal和v.tangent)
										//rotation将模型空间下的方向转换到切线空间下
				f.lightDir = mul(ObjSpaceLightDir(v.vertex), rotation);

				return f;
			}

			fixed4 frag(v2f f) : SV_Target{

				//漫反射
				fixed3 normalTemp = UnpackNormal(tex2D(_NormalMap,f.texcoord.zw));
				normalTemp.xy  *= _BumpScale;
				fixed3 normalDir = normalize(normalTemp);
				fixed3 lightDir = normalize(f.lightDir);
				fixed3 diffuse = _LightColor0.rgb * (0.5 * dot(normalDir, lightDir) + 0.5);

				//BP高光反射
				//fixed3 reflectDir = normalize(reflect(-lightDir, normalDir));
				//fixed3 viewDir = normalize(WorldSpaceViewDir(f.vertex));
				//fixed3 halfDir = normalize(viewDir + lightDir);
				//fixed3 specular = _LightColor0.rgb * pow(max(0, dot(normalDir, halfDir)), _Gross);

				//纹理
				fixed3 texColor = tex2D(_MainTex, f.texcoord.xy).xyz;

				return fixed4(diffuse  * texColor, 1);
			}

			ENDCG
		}
    }
    FallBack "VertexLit"
}
