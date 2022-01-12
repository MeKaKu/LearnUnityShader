Shader "Custom/shader-11"
{	//纹理贴图 + 逐像素半兰伯特漫反射
    Properties
    {
		_MainTex("Main Texture",2D) = "white"{}
		_Gross("Gross",Range(5,30)) = 10
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
			float4 _MainTex_ST;
			half _Gross;
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};
			struct v2f {
				float4 position : SV_POSITION;
				float3 normal : COLOR0;
				float4 vertex : COLOR1;
				float4 texcoord : TEXCOORD0;
			};
			v2f vert(a2v v) {
				v2f f;
				f.position = UnityObjectToClipPos(v.vertex);
				f.normal = v.normal;
				f.vertex = v.vertex;
				f.texcoord = float4(v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw,0,0);
				return f;
			}

			fixed4 frag(v2f f) : SV_Target{
				//漫反射
				fixed3 normalDir = normalize(UnityObjectToWorldNormal(f.normal));
				fixed3 lightDir = normalize(WorldSpaceLightDir(f.vertex));
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
