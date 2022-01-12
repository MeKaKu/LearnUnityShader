Shader "MyShaders/OutLine"{
    Properties{
        _OutLineColor("OutLineColor",Color) = (0,0,0,1)
        _OutLineWidth("OutLineWidth",Range(0.001,0.01)) = 0.005

    }

    SubShader{
        Tags {"Queue"="Geometry+1"}
        CGINCLUDE
        #include "Lighting.cginc"
        fixed4 _OutLineColor;
        fixed _OutLineWidth;
        struct a2v{
            float4 position : POSITION;
            float3 normal : NORMAL;
        };
        struct v2f{
            float4 position : SV_POSITION;
        };
        v2f vert(a2v a){
            v2f v;
            float4 worldPos = mul(unity_ObjectToWorld,a.position);
            float camDis = distance(worldPos,_WorldSpaceCameraPos);
            a.position.xyz += normalize(a.normal)*camDis*_OutLineWidth;
            v.position = UnityObjectToClipPos(a.position);
            return v;
        }
        fixed4 frag(v2f f):SV_Target{
            return _OutLineColor;
        }
        ENDCG
        Pass{
            Tags{"LightMode"="ForwardBase"}
            //ZWrite off
            Cull Front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            ENDCG
        }
        Pass{
            Tags{"LightMode"="ForwardBase"}
        }
    }
    Fallback "VertexLit"
}