Shader "MyShaders/ToonSample"{
    Properties{
        _Color("Color",Color) = (1,1,1,1)
        _DiffuseColor("DiffuseColor",Color) = (0.5,0.5,0.9,1)
        _AmbientColor("AmbientColor",Color) = (0.2,0.2,0.4,1)
        _SpecularColor("SpecularColor",Color) = (0.7,0.7,1,1)
        _RimColor("RimColor",Color) = (0.7,0.7,1,1)
        _Gloss("Gloss",Float) = 32

        _OutLineColor("OutLineColor",Color) = (0,0,0,1)
        _OutLineWidth("OutLineWidth",Range(0.001,0.01)) = 0.005
    }

    SubShader{
        Tags{
            "LightMode" = "ForwardBase"
            "PassFlag" = "OnlyDirectional"
        }
        CGINCLUDE
        #include "Lighting.cginc"
        #include "AutoLight.cginc"
        fixed4 _Color;
        fixed4 _DiffuseColor;
        fixed4 _AmbientColor;
        fixed4 _SpecularColor;
        fixed4 _RimColor;
        fixed4 _OutLineColor;
        fixed _OutLineWidth;
        fixed _Gloss;
        struct appData{
            float4 position : POSITION;
            float3 normal : NORMAL;
        };
        struct v2f{
            float4 pos : SV_POSITION;
            float3 normal : NORMAL;
            float3 viewDir : COLOR0;
            SHADOW_COORDS(2) //屏幕阴影图坐标存放空间
        };
        v2f vert(appData a){
            v2f f;
            f.pos = UnityObjectToClipPos(a.position);
            f.normal = UnityObjectToWorldNormal(a.normal);
            f.viewDir = WorldSpaceViewDir(a.position);
            TRANSFER_SHADOW(f); //计算屏幕阴影图坐标
            return f;
        }
        fixed4 frag(v2f f) : SV_TARGET{
            float3 normal = normalize(f.normal);
            float3 viewDir = normalize(f.viewDir);
            float shadow = SHADOW_ATTENUATION(f); //阴影采样，阴影值[0，1]
            //DIFFUSE
            fixed diffuseFacr = max(0,dot(_WorldSpaceLightPos0,normal));
            fixed diffuseFac = smoothstep(0,0.03,diffuseFacr);
            fixed4 diffuse = _DiffuseColor * diffuseFac;

            //SPECULAR
            float3 halfDir = normalize(viewDir + _WorldSpaceLightPos0);
            fixed specularFacr = pow(max(0,dot(normal,halfDir)),_Gloss*_Gloss);
            fixed specularFac = smoothstep(0.005,0.01,specularFacr);
            fixed4 specular = _SpecularColor * specularFac;

            //RIM
            fixed rimFacr = 1 - max(0,dot(normal,viewDir));
            rimFacr *= pow(diffuseFacr,0.1);
            fixed rimFac = smoothstep(0.72,0.75,rimFacr);
            fixed4 rim = rimFac * _RimColor;

            //_AmbientColor
            fixed4 ambient = _AmbientColor * 0.5;

            return _Color * (ambient + (diffuse + specular + rim)*shadow);
        }
        v2f vertOL(appData a){
            v2f v;
            a.position.xyz += normalize(a.normal)*_OutLineWidth;
            v.pos = UnityObjectToClipPos(a.position);
            return v;
        }
        fixed4 fragOL(v2f f):SV_Target{
            return _OutLineColor;
        }
        ENDCG
        Pass{ //该pass用于产生外轮廓
            Cull Front
            CGPROGRAM
            #pragma vertex vertOL
            #pragma fragment fragOL

            ENDCG
        }
        Pass{ //卡通风格渲染
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            ENDCG
        }
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER" //添加ShaCaster Pass，投射阴影
    }
    Fallback "VertexLit"
}