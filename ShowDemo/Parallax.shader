Shader "Custom/Parallax" {
 
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_Parallax ("Height", Range (0.005, 0.08)) = 0.02
	_MainTex ("Base (RGB)", 2D) = "white" {}
	_BumpMap ("Normalmap", 2D) = "bump" {}
	_ParallaxMap ("Heightmap (A)", 2D) = "black" {}
	 [Toggle] _UseMain("UseMain",float)=1
	 
}

CGINCLUDE
sampler2D _MainTex;
sampler2D _BumpMap;
sampler2D _ParallaxMap;
fixed4 _Color;
float _Parallax;
float _UseMain;
  struct Input {
	float2 uv_MainTex;
	float2 uv_BumpMap;
	float3 viewDir;
};
 float2 ParallaxUvDelta2(Input i)
{
 
    float3 viewDir = normalize(i.viewDir);
 

float step=2.0/12;
    // 单层步进的高度
    float layerHeight = 1.0*step;
    // 最高的高度值
    float currentLayerHeight = 1.0;
     float lenLimit=length(viewDir.xy)/viewDir.z*0.04;
    // delta 最大值
    float2 P = viewDir.xy/viewDir.z *_Parallax; 
    // delta 单步逼近值
    float2 deltaTexCoords = P *step;
   


    // 开始一步步逼近，直到找到合适的红点
    float2 currentTexCoords = i.uv_MainTex;
    float currentDepthMapValue = 0;

   for(int k=0;k<12;k++)
    {
    //if(lenLimit<0)break;
    if(currentLayerHeight < currentDepthMapValue){
 
    currentTexCoords+=deltaTexCoords;
            currentLayerHeight+= layerHeight; 
            lenLimit+=length(deltaTexCoords);
               step/=2;
               layerHeight = 1.0*step;
               deltaTexCoords = P *step;
             

    }
    lenLimit-=length(deltaTexCoords);
        currentTexCoords -= deltaTexCoords;
        currentDepthMapValue = tex2D(_ParallaxMap, currentTexCoords).r;  
        currentLayerHeight -= layerHeight;  
    }
    
    
  //  return currentTexCoords-i.uv_MainTex;
    // 计算 h1 和 h2
    float2 prevTexCoords = currentTexCoords + deltaTexCoords;
    float afterHeight  = currentDepthMapValue - currentLayerHeight;
    float beforeHeight = currentLayerHeight + layerHeight - tex2D(_ParallaxMap, prevTexCoords).r;
    // 利用 h1 h2 得到权重，在两个红点间使用权重进行差值
    float weight = afterHeight / (afterHeight + beforeHeight);
    float2 finalTexCoords = prevTexCoords * weight + currentTexCoords * (1.0 - weight);
      return (finalTexCoords - i.uv_MainTex);
 
     
}
  float2 ParallaxUvDelta(Input i)
{
    float3 viewDir = normalize(i.viewDir);
    
    // 细分的层数
    const int numLayers = 30;

    // 单层步进的高度
    float layerHeight = 1.0 / numLayers;
    // 最高的高度值
    float currentLayerHeight = 1.0;
    // delta 最大值
    float2 P = viewDir.xy/viewDir.z * _Parallax; 
    // delta 单步逼近值
    float2 deltaTexCoords = P / numLayers;
   


    // 开始一步步逼近，直到找到合适的红点
    float2 currentTexCoords = i.uv_MainTex;
    float currentDepthMapValue = tex2D(_ParallaxMap, currentTexCoords).r;

   for(int k=0;k<numLayers;k++)
    {
    if(currentLayerHeight < currentDepthMapValue)break;
        currentTexCoords -= deltaTexCoords;
        currentDepthMapValue = tex2D(_ParallaxMap, currentTexCoords).r;  
        currentLayerHeight -= layerHeight;  
    }
    
    
    
    // 计算 h1 和 h2
    float2 prevTexCoords = currentTexCoords + deltaTexCoords;
    float afterHeight  = currentDepthMapValue - currentLayerHeight;
    float beforeHeight = currentLayerHeight + layerHeight - tex2D(_ParallaxMap, prevTexCoords).r;
    // 利用 h1 h2 得到权重，在两个红点间使用权重进行差值
    float weight = afterHeight / (afterHeight + beforeHeight);
    float2 finalTexCoords = prevTexCoords * weight + currentTexCoords * (1.0 - weight);
    
    return (finalTexCoords - i.uv_MainTex)*( pow(abs(dot(half3(0,0,1),viewDir)),0.2)+0.8)/1.8;
    
     
}
// Calculates UV offset for parallax bump mapping
inline float2 ParallaxOffsetModify( half h, half height, half3 viewDir )
{
 return viewDir.xy / viewDir.z * (h-0.5) * height;
    h = h * height - height/2.0;
    float3 v = normalize(viewDir);
    v.z += 0.42;
    return h * (v.xy / v.z);
}
void surf (Input IN, inout SurfaceOutput o) {
	half h = tex2D (_ParallaxMap, IN.uv_BumpMap).r;
	//float2 offset = ParallaxOffsetModify (h, _Parallax, IN.viewDir);
	//float2 offset=(ParallaxUvDelta(IN)+ParallaxUvDelta2(IN))/2;
	float2 offset =  _UseMain>0.5?  ParallaxUvDelta(IN):ParallaxUvDelta2(IN);
	 IN.uv_MainTex += offset;
	 IN.uv_BumpMap += offset;
	
	fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
	o.Albedo = (c.rgb+0.2)/1.2;
	o.Alpha = c.a;
	o.Normal = UnpackScaleNormal(tex2D(_BumpMap, IN.uv_BumpMap),-1);
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