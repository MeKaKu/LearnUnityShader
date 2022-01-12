Shader "MyShaders/ToonWaterShader"{
    Properties{
        _ShallowColor("ShallowColor",Color) = (0.325, 0.807, 0.971, 0.725)
        _DeepColor("DeepColor",Color) = (0.086, 0.407, 1, 0.749)
        _MaxDepth("MaxDepth",Float) = 1
        _SurfaceNoise("Surface Noise",2D) = "white"{}
        _SurfaceNoiseCutOff("Surface Noise Cut Off",Range(0,1)) = 0.777 //噪声去除的阈值
        _FoamDistance("Foam Distance",Float) = 4 //泡沫
        _SurfaceNoiseScroll("Surface Noise Scroll",Vector) = (0.03,0.03,0,0)//噪声偏移
        _SurfaceDistortion("Surface Destortion",2D) = "white"{} //水面扰动贴图
        _SurfaceDistortionAmount("Surface Distortion Amount",Range(0,1)) = 0.27 //扰动程度
    }
    SubShader{
        Tags {
            "Queue" = "Geometry+1"
        }
        CGINCLUDE
        #include "Lighting.cginc"
        fixed4 _ShallowColor;
        fixed4 _DeepColor;
        float _MaxDepth;
        sampler2D _CameraDepthTexture;//深度图
        sampler2D _SurfaceNoise; //噪声纹理
        float4 _SurfaceNoise_ST; //Unity自动填充 Tilling 和 Offset 
        float _SurfaceNoiseCutOff;
        float _FoamDistance;
        float2 _SurfaceNoiseScroll;
        sampler2D _SurfaceDistortion;
        float4 _SurfaceDistortion_ST;
        float _SurfaceDistortionAmount;

        struct appData{
            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float4 uv : TEXCOORD0;
        };
        struct v2f{
            float4 pos: SV_POSITION;
            float3 normal : NORMAL;
            float4 screenPos : TEXCOORD2;
            float2 noiseUV : TEXCOORD0;
            float2 distortionUV : TEXCOORD1;
        };
        v2f vert(appData a){
            v2f f;
            f.pos = UnityObjectToClipPos(a.vertex);
            f.normal = UnityObjectToWorldNormal(a.normal);
            f.screenPos = ComputeScreenPos(f.pos);//世界空间点在屏幕空间的坐标
            f.noiseUV = TRANSFORM_TEX(a.uv,_SurfaceNoise); //UV坐标转换，计算Tilling和Offset之后的UV
            f.distortionUV = TRANSFORM_TEX(a.uv,_SurfaceDistortion);
            return f;
        }
        fixed4 frag(v2f f) : SV_TARGET{
            float existingDepth01 = tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD(f.screenPos)).r;//对深度图采样，[0,1](1/z)
            float existingDepthLinear = LinearEyeDepth(existingDepth01);//转换成线性深度值
            float depthDifference = existingDepthLinear - f.screenPos.w;//屏幕空间下，w是深度值
            float waterDepthDifference01 = saturate(depthDifference/_MaxDepth);
            fixed4 waterColor = lerp(_ShallowColor, _DeepColor, waterDepthDifference01);

            float2 distortionSample = (tex2D(_SurfaceDistortion,f.distortionUV).xy*2 - 1) * _SurfaceDistortionAmount;
            //动画，Time.y与时间相关，_SurfaceNoiseScroll是UV.xy的偏移量
            float2 noiseUV = float2(f.noiseUV.x + _Time.y*_SurfaceNoiseScroll.x+distortionSample.x,f.noiseUV.y+_Time.y*_SurfaceNoiseScroll.y+distortionSample.y);
            float surfaceNoiseSample = tex2D(_SurfaceNoise,noiseUV).r;//纹理采样
            
            float foamDistance01 = saturate(depthDifference/_FoamDistance);
            float surfaceNoiseCutOff = _SurfaceNoiseCutOff * foamDistance01;
            float surfaceNoise = surfaceNoiseSample > surfaceNoiseCutOff ? 1 : 0;

            return waterColor + surfaceNoise;
        }
        ENDCG
        Pass{
            //Cull Back
            //ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
    }
}