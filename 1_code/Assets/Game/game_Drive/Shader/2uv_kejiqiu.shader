// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:3138,x:33054,y:32769,varname:node_3138,prsc:2|emission-7226-OUT,alpha-3683-OUT,voffset-3578-OUT;n:type:ShaderForge.SFN_Color,id:7241,x:32156,y:32563,ptovrint:False,ptlb:Color,ptin:_Color,varname:node_7241,prsc:2,glob:False,taghide:False,taghdr:True,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_VertexColor,id:1460,x:32128,y:33085,varname:node_1460,prsc:2;n:type:ShaderForge.SFN_Tex2d,id:3501,x:32146,y:32739,ptovrint:False,ptlb:uv1tex,ptin:_uv1tex,varname:node_3501,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:7226,x:32398,y:32663,varname:node_7226,prsc:2|A-7241-RGB,B-3501-RGB;n:type:ShaderForge.SFN_Multiply,id:6066,x:32524,y:33034,varname:node_6066,prsc:2|A-3501-A,B-9424-OUT;n:type:ShaderForge.SFN_Fresnel,id:7904,x:32146,y:32899,varname:node_7904,prsc:2|EXP-603-OUT;n:type:ShaderForge.SFN_Slider,id:603,x:31775,y:32906,ptovrint:False,ptlb:edge,ptin:_edge,varname:node_603,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:10;n:type:ShaderForge.SFN_Add,id:3683,x:32728,y:32951,varname:node_3683,prsc:2|A-7904-OUT,B-6066-OUT;n:type:ShaderForge.SFN_Tex2d,id:56,x:32128,y:33280,ptovrint:False,ptlb:uv2tex,ptin:_uv2tex,varname:node_56,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-720-UVOUT;n:type:ShaderForge.SFN_TexCoord,id:3609,x:31489,y:33212,varname:node_3609,prsc:2,uv:2,uaff:False;n:type:ShaderForge.SFN_Add,id:9424,x:32323,y:33228,varname:node_9424,prsc:2|A-1460-A,B-56-A;n:type:ShaderForge.SFN_NormalVector,id:6737,x:32209,y:33445,prsc:2,pt:False;n:type:ShaderForge.SFN_Multiply,id:3578,x:32545,y:33409,varname:node_3578,prsc:2|A-56-A,B-6737-OUT,C-7170-OUT;n:type:ShaderForge.SFN_ValueProperty,id:7170,x:32186,y:33617,ptovrint:False,ptlb:node_7170,ptin:_node_7170,varname:node_7170,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Panner,id:720,x:31825,y:33268,varname:node_720,prsc:2,spu:0,spv:0.6|UVIN-3609-UVOUT;proporder:7241-3501-603-56-7170;pass:END;sub:END;*/

Shader "Shader Forge/2uv_kejiqiu" {
    Properties {
        [HDR]_Color ("Color", Color) = (1,1,1,1)
        _uv1tex ("uv1tex", 2D) = "white" {}
        _edge ("edge", Range(0, 10)) = 0
        _uv2tex ("uv2tex", 2D) = "white" {}
        _node_7170 ("node_7170", Float ) = 1
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform float4 _Color;
            uniform sampler2D _uv1tex; uniform float4 _uv1tex_ST;
            uniform float _edge;
            uniform sampler2D _uv2tex; uniform float4 _uv2tex_ST;
            uniform float _node_7170;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
                float2 texcoord2 : TEXCOORD2;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float4 posWorld : TEXCOORD2;
                float3 normalDir : TEXCOORD3;
                float4 vertexColor : COLOR;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.uv2 = v.texcoord2;
                o.vertexColor = v.vertexColor;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                float4 node_1047 = _Time;
                float2 node_720 = (o.uv2+node_1047.g*float2(0,0.6));
                float4 _uv2tex_var = tex2Dlod(_uv2tex,float4(TRANSFORM_TEX(node_720, _uv2tex),0.0,0));
                v.vertex.xyz += (_uv2tex_var.a*v.normal*_node_7170);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                i.normalDir = normalize(i.normalDir);
                i.normalDir *= faceSign;
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
////// Lighting:
////// Emissive:
                float4 _uv1tex_var = tex2D(_uv1tex,TRANSFORM_TEX(i.uv0, _uv1tex));
                float3 emissive = (_Color.rgb*_uv1tex_var.rgb);
                float3 finalColor = emissive;
                float4 node_1047 = _Time;
                float2 node_720 = (i.uv2+node_1047.g*float2(0,0.6));
                float4 _uv2tex_var = tex2D(_uv2tex,TRANSFORM_TEX(node_720, _uv2tex));
                return fixed4(finalColor,(pow(1.0-max(0,dot(normalDirection, viewDirection)),_edge)+(_uv1tex_var.a*(i.vertexColor.a+_uv2tex_var.a))));
            }
            ENDCG
        }
        Pass {
            Name "ShadowCaster"
            Tags {
                "LightMode"="ShadowCaster"
            }
            Offset 1, 1
            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform sampler2D _uv2tex; uniform float4 _uv2tex_ST;
            uniform float _node_7170;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord2 : TEXCOORD2;
            };
            struct VertexOutput {
                V2F_SHADOW_CASTER;
                float2 uv2 : TEXCOORD1;
                float4 posWorld : TEXCOORD2;
                float3 normalDir : TEXCOORD3;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv2 = v.texcoord2;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                float4 node_4487 = _Time;
                float2 node_720 = (o.uv2+node_4487.g*float2(0,0.6));
                float4 _uv2tex_var = tex2Dlod(_uv2tex,float4(TRANSFORM_TEX(node_720, _uv2tex),0.0,0));
                v.vertex.xyz += (_uv2tex_var.a*v.normal*_node_7170);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                TRANSFER_SHADOW_CASTER(o)
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                i.normalDir = normalize(i.normalDir);
                i.normalDir *= faceSign;
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
