Shader "Custom/Parallax2" {
 
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_Parallax ("Height", Range (0.005, 0.08)) = 0.02
	_MainTex ("Base (RGB)", 2D) = "white" {}
	_BumpMap ("Normalmap", 2D) = "bump" {}
	_ParallaxMapZ ("_ParallaxOffsetZ", 2D) = "black" {}
 	 
}

CGINCLUDE
sampler2D _MainTex;
sampler2D _BumpMap;
sampler2D _ParallaxMapZ;
fixed4 _Color;
float _Parallax;
float _UseMain;
  struct Input {
	float2 uv_MainTex;
	float2 uv_BumpMap;
	float3 viewDir;
};
    
void surf (Input IN, inout SurfaceOutput o) {
  

   float rot= atan2(IN.viewDir.y,IN.viewDir.z)*180/3.1415;
    
 float4 offsetData=tex2D( _ParallaxMapZ,IN.uv_MainTex);
 //  offsetData.rgba=offsetData.abgr;
	float2 offset = 0; 
	if(rot<-60){
	offset.y=offsetData.r;
	}else if(rot<-30){
	offset.y=lerp(offsetData.r,offsetData.g,(rot+60)/30);
	}else if(rot<0){
	
	
	offset.y=lerp(offsetData.g,0,(rot+30)/30);
	} else if(rot <30){
	offset.y=lerp(0,offsetData.b,(rot)/30);
	}else if(rot <60){
	offset.y=lerp(offsetData.b,offsetData.a,(rot-30)/30);
	}else{
	offset.y=offsetData.a;
	}
	 
	offset/=10;
	 
	 IN.uv_MainTex += offset;
	 IN.uv_BumpMap += offset;
	
	fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
	o.Albedo = (c.rgb+0.2)/1.2;
	o.Alpha = c.a;
	o.Normal = UnpackScaleNormal(tex2D(_BumpMap, IN.uv_BumpMap),-1);
	//o.Albedo = rot<60?1:0;
}
ENDCG

SubShader {
	Tags { "RenderType"="Opaque" }
	LOD 500

	CGPROGRAM
	#pragma surface surf Lambert
	#pragma target 5.0
	ENDCG
}

SubShader {
	Tags { "RenderType"="Opaque" }
	LOD 500

	CGPROGRAM
	#pragma surface surf Lambert nodynlightmap
	ENDCG
}

FallBack "Legacy Shaders/Bumped Diffuse"
}