// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/bianyuan"
{
    Properties
    {
		_offsetX("_offsetX",Range(0,1)) = 1
        _offsetY("_offsetY",Range(0,1)) = 1
		_offsetZ("_offsetZ",Range(0,1)) = 1
		_offsetW("_offsetW",Range(0,1)) = 1
    }
 
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include"UnityCG.cginc"
 
            struct v2f
            {
                float4 vertex:POSITION;
                float4 uv:TEXCOORD0;
                float4 NdotV:COLOR;
            };
 
            sampler2D _MainTex;
            float4 _RimColor;
            float _RimPower;
			float _offsetY;
			float _offsetX;
			float _offsetZ;
			float _offsetW;
            v2f vert(appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                float3 V = WorldSpaceViewDir(v.vertex);
                V = mul(unity_WorldToObject,V);//视方向从世界到模型坐标系的转换
                o.NdotV.x = saturate(dot(v.normal,normalize(V)));//必须在同一坐标系才能正确做点乘运算
                return o;
            }
 
            half4 frag(v2f IN):COLOR
            {
                // half4 c = tex2D(_MainTex,IN.uv);
                // //用视方向和法线方向做点乘，越边缘的地方，法线和视方向越接近90度，点乘越接近0.
                // //用（1- 上面点乘的结果）*颜色，来反映边缘颜色情况
                // c.rgb += pow((1-IN.NdotV.x) ,_RimPower) * _RimColor.rgb;
				fixed4 color = fixed4(1,1,1,0);
				float x = abs(1-IN.uv.x);
				float y = abs(1-IN.uv.y);
				float z = abs(1-IN.uv.z);
				float w = abs(1-IN.uv.w);
				if(x < _offsetX){
					color = fixed4(0,0,1,1);
				}
				if(y < _offsetY){
					color = fixed4(0,0,1,1);
				}
				if(x > 1- _offsetX){
					color = fixed4(0,0,1,1);
				}
				if(y > 1- _offsetY){
					color = fixed4(0,0,1,1);
				}
				// if(z < _offsetZ){
				// 	color = fixed4(0,0,1,1);
				// }
				// if(w < _offsetW){
				// 	color = fixed4(0,0,1,1);
				// }
                return color;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}