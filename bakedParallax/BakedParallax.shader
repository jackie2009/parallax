Shader "Custom/BakedParallax" {
 
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_Parallax ("Height", Range (0.005, 0.08)) = 0.02
	_MainTex ("Base (RGB)", 2D) = "white" {}
	_BumpMap ("Normalmap", 2D) = "bump" {}
	_ParallaxMapX ("_ParallaxOffsetX", 2D) = "black" {}
	_ParallaxMapZ ("_ParallaxOffsetZ", 2D) = "black" {}
 	 
}

CGINCLUDE
sampler2D _MainTex;
sampler2D _BumpMap;
sampler2D _ParallaxMapX;
sampler2D _ParallaxMapZ;
fixed4 _Color;
float _Parallax;
float _UseMain;
  struct Input {
	float2 uv_MainTex;
	float2 uv_BumpMap;
	float3 viewDir;
};
  float getOffset(half4  offsetData,float viewDirX_Y,float viewDirZ,float wight) {
	  float rot = atan2(viewDirZ, viewDirX_Y) * 180 / 3.1415926;
	  float p = 1;
	   rot = lerp(90, rot, pow(wight,4));
	  // offsetData.rgba=offsetData.abgr;
	  //  offsetData*=1.5;
	  float offset = 0;
	  if (rot > 150) {
		  offset = offsetData.r;
	  }
	  else if (rot >120) {
		  offset = lerp(offsetData.r, offsetData.g, 1-pow((rot -120) / 30, p));
	  }
	  else if (rot >90) {


		  offset = lerp(offsetData.g, 0, 1-pow((rot -90) / 30, p));
	  }
	  else if (rot > 60) {
		  offset = lerp(0, offsetData.b,1- pow((rot-60) / 30, p));
	  }
	  else if (rot >30) {
		  offset = lerp(offsetData.b, offsetData.a,1- pow((rot - 30) / 30, p));
	  }
	  else {
		  offset = offsetData.a;
	  }

	  offset /= 10;
	  return offset;
  }
void surf (Input IN, inout SurfaceOutput o) {
  

 
	half4 offsetDataX=tex2D( _ParallaxMapX,IN.uv_MainTex);
	half4 offsetDataZ=tex2D( _ParallaxMapZ,IN.uv_MainTex);
	offsetDataX.rgba = offsetDataX.abgr;
	float xWight = abs(IN.viewDir.x) / (abs(IN.viewDir.x) + abs(IN.viewDir.y));
 xWight = xWight * xWight;
	
	float2 offset = float2(getOffset(offsetDataX,IN.viewDir.x,IN.viewDir.z, xWight),getOffset(offsetDataZ, IN.viewDir.y, IN.viewDir.z,1- xWight));
      offset *= half2(xWight, 1 - xWight);
	 //offset *= 0.6;
	IN.uv_MainTex += offset;
	 IN.uv_BumpMap += offset;
	
	fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
	o.Albedo = (c.rgb+0.2)/1.2;
	o.Alpha = c.a;
	o.Normal = UnpackScaleNormal(tex2D(_BumpMap, IN.uv_BumpMap),-1);
	 float rot = atan2(IN.viewDir.z, IN.viewDir.x) * 180 / 3.1415926;
	 // o.Albedo = rot<150?1:0;
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