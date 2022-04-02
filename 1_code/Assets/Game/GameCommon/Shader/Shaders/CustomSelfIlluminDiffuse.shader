// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Custom/Legacy Shaders/Self-Illumin/Diffuse" {
	Properties{
		_Color("Main Color", Color) = (1,1,1,1)
		_MainTex("Base (RGB)", 2D) = "white" {}
		_Illum("Illumin (A)", 2D) = "white" {}
		_Emission("Emission (Lightmapper)", Float) = 0
	}
		SubShader{
			Tags { "RenderType" = "Opaque" }
			LOD 200

		CGPROGRAM
		#pragma surface surf Lambert 

		half4 LightingUnlit(SurfaceOutput s, half3 lightDir, half atten) {
			return half4(s.Albedo, s.Alpha);
		}

		sampler2D _MainTex;
		fixed4 _Color;
		fixed _Emission;

		struct Input {
			float2 uv_MainTex;
			float2 uv_Illum;
		};

		void surf(Input IN, inout SurfaceOutput o) {
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
			o.Albedo = c.rgb;
			o.Emission = _Emission;
			o.Alpha = c.a;
		}

		ENDCG
		}
			FallBack "Legacy Shaders/Self-Illumin/VertexLit"
			CustomEditor "LegacyIlluminShaderGUI"
}
