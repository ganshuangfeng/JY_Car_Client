// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "circle" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _Width("RoundWidth", Range(0.1, 1000)) = 10
    }

    SubShader {
        /*Pass {
                ZTest Off
                ZWrite Off
                ColorMask 0
        }*/

        Pass {
            Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM

            #include "UnityCG.cginc"
            #pragma vertex vert
            #pragma fragment frag


            struct v2f {
                float4 pos : SV_POSITION;
                float4 oPos : TEXCOORD1;
            };
            fixed4 _Color;
            half _Width;

            float4 _MainTex_ST;
            v2f vert (appdata_base v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.oPos = v.vertex;
                return o;
            }

            fixed4 frag(v2f i) : COLOR{
                float dis = sqrt(i.oPos.x * i.oPos.x + i.oPos.y * i.oPos.y);
                float maxDistance = 0.5;

                float ringWorldRange = unity_ObjectToWorld[0][0];
                float minDistance =(ringWorldRange * 0.5 - _Width)/ringWorldRange;

                _Color.a = step(dis, 0.5);
                _Color.a = _Color.a * step(minDistance, dis);
                _Color.a = _Color.a * (dis - minDistance)/(0.5 - minDistance);

                return _Color;
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}
