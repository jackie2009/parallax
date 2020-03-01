Shader "Custom/Parallax" {
 
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_Parallax ("Height", Range (0.005, 0.28)) = 0.02
	lenLimit ("lenLimit", Range (0.01, 10)) = 0.02
	  
      numLayers (" 细分的层数", Range (1, 100)) = 8
	_MainTex ("Base (RGB)", 2D) = "white" {}
	_BumpMap ("Normalmap", 2D) = "bump" {}
	_ParallaxMap ("Heightmap (A)", 2D) = "black" {}
	 [Toggle] _UseMain("UseMain",float)=1
	 [Toggle] _Shadow("Shadow",float)=1
	 [Toggle] _UseDither("_UseDither",float)=0
	 
}

CGINCLUDE
sampler2D _MainTex;
sampler2D _BumpMap;
sampler2D _ParallaxMap;
sampler2D _Dither_Tex;
fixed4 _Color;
float _Parallax;
float _UseMain;
float numLayers;
float lenLimit;
float _Shadow;
float _UseDither;
  struct Input {
	float2 uv_MainTex;
	float2 uv_BumpMap;
	float3 viewDir;
	float3 MainLightDir;
	float3 screenPos;
};
 float2 ParallaxUvDelta2(Input i,out float initialHeight)
{
     float3 viewDir = normalize(i.viewDir);
 

float step=1.0/(numLayers-3);
 float2 startCoords=i.uv_MainTex;
 

 
 

    // 单层步进的高度
    float layerHeight = 1.0*step;
    // 最高的高度值
    float currentLayerHeight = 1.0;
     
     
    // delta 最大值
    float2 P = viewDir.xy/viewDir.z *_Parallax;
   if( length(P)>lenLimit ) P=lenLimit*normalize(P);
    // delta 单步逼近值
    float2 deltaTexCoords = P *step;
   
 //dither
 if(_UseDither>0.5){
				float2 offsetUV = i.screenPos.xy*1920;
				float ditherValue = tex2D(_Dither_Tex, offsetUV).a;
				
				 
				startCoords = startCoords + deltaTexCoords * ditherValue/4;
}

    // 开始一步步逼近，直到找到合适的红点
    float2 currentTexCoords =startCoords ;
    float currentDepthMapValue = 0;

   for(int k=0;k<numLayers;k++)
    {
    
    
    if(currentLayerHeight < currentDepthMapValue){
 
    currentTexCoords+=deltaTexCoords;
            currentLayerHeight+= layerHeight; 
       
       
               step/=2;
               layerHeight = 1.0*step;
               deltaTexCoords = P *step;
           //  k--;

    }


        currentTexCoords -= deltaTexCoords;
        currentDepthMapValue = tex2Dlod(_ParallaxMap, half4(currentTexCoords,0,0)).r;  
        currentLayerHeight -= layerHeight;  
    }
    
     initialHeight=currentLayerHeight;
  //  return currentTexCoords-i.uv_MainTex;
    // 计算 h1 和 h2
    float2 prevTexCoords = currentTexCoords + deltaTexCoords;
    float afterHeight  = currentDepthMapValue - currentLayerHeight;
    float beforeHeight = currentLayerHeight + layerHeight - tex2D(_ParallaxMap, prevTexCoords).r;
    // 利用 h1 h2 得到权重，在两个红点间使用权重进行差值
    float weight = afterHeight / (afterHeight + beforeHeight);
    float2 finalTexCoords = prevTexCoords * weight + currentTexCoords * (1.0 - weight);
      return  (finalTexCoords - startCoords);
 
     
}
  float2 ParallaxUvDelta(Input i,out float initialHeight)
{
    float3 viewDir = normalize(i.viewDir);
    
 

    // 单层步进的高度
    float layerHeight = 1.0 / numLayers;
    // 最高的高度值
    float currentLayerHeight = 1.0;
    // delta 最大值
    float2 P = viewDir.xy/viewDir.z *_Parallax;
   if( length(P)>lenLimit ) P=lenLimit*normalize(P);
    float2 deltaTexCoords = P / numLayers;
   


    // 开始一步步逼近，直到找到合适的红点
    float2 currentTexCoords = i.uv_MainTex;
    float currentDepthMapValue = tex2D(_ParallaxMap, currentTexCoords).r;
 
   for(int k=0;k<numLayers;k++)
    {
    if(currentLayerHeight < currentDepthMapValue)break;
        currentTexCoords -= deltaTexCoords;
        currentDepthMapValue = tex2Dlod(_ParallaxMap, half4(currentTexCoords,0,0)).r;  
        currentLayerHeight -= layerHeight;  
    }
    
    
    initialHeight=currentLayerHeight;
    // 计算 h1 和 h2
    float2 prevTexCoords = currentTexCoords + deltaTexCoords;
    float afterHeight  = currentDepthMapValue - currentLayerHeight;
    float beforeHeight = currentLayerHeight + layerHeight - tex2D(_ParallaxMap, prevTexCoords).r;
    // 利用 h1 h2 得到权重，在两个红点间使用权重进行差值
    float weight = afterHeight / (afterHeight + beforeHeight);
    float2 finalTexCoords = prevTexCoords * weight + currentTexCoords * (1.0 - weight);
    
   // return (finalTexCoords - i.uv_MainTex);//*( pow(abs(dot(half3(0,0,1),viewDir)),0.2)+0.8)/1.8;
     return (finalTexCoords - i.uv_MainTex);
     
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
float parallaxSoftShadowMultiplier(  half3 L,   half2 initialTexCoord,
                                         float initialHeight)
{
 

   const float minLayers = 5;
   const float maxLayers = 15;
 int hitTime=0;
   // calculate lighting only for surface oriented to the light source
   if(initialHeight<0.6&&dot(half3(0, 0, 1), L) > 0)
   {
      // calculate initial parameters
      float numSamplesUnderSurface    = 0;
      
      float numLayers    = lerp(maxLayers, minLayers, abs(dot(half3(0, 0, 1), L)));
      
       
    
 

    // 单层步进的高度
    float layerHeight = 1.0 / numLayers;
    // 最高的高度值
    float currentLayerHeight = initialHeight;
    // delta 最大值
    float2 P = L.xy/L.z *_Parallax;
   if( length(P)>lenLimit ) P=lenLimit*normalize(P);
    float2 deltaTexCoords = P / numLayers;
   


    // 开始一步步逼近，直到找到合适的红点
    float2 currentTexCoords = initialTexCoord;
    float currentDepthMapValue = tex2D(_ParallaxMap, currentTexCoords).r;

   for(int k=0;k<numLayers;k++)
    {
    if(currentLayerHeight>1)break;
    if(currentLayerHeight < currentDepthMapValue) hitTime++;
        currentTexCoords += deltaTexCoords;
        currentDepthMapValue = tex2Dlod(_ParallaxMap, half4(currentTexCoords,0,0)).r;  
        currentLayerHeight += layerHeight;  
    }
    
    
    
    /*  float layerHeight    = initialHeight / numLayers;
      half2 texStep    = _Parallax * L.xy / L.z / numLayers;

      // current parameters
      float currentLayerHeight    = initialHeight - layerHeight;
      half2 currentTextureCoords    = initialTexCoord + texStep;
      float heightFromTexture    =tex2Dlod(_ParallaxMap, half4(currentTextureCoords,0,0)).r;  
       int stepIndex    = 1;

      // while point is below depth 0.0 )
      while(currentLayerHeight > 0)
      {
         // if point is under the surface
         if(heightFromTexture < currentLayerHeight)
         {
            // calculate partial shadowing factor
            numSamplesUnderSurface    += 1;
            float newShadowMultiplier    = (currentLayerHeight - heightFromTexture) *
                                             (1.0 - stepIndex / numLayers);
            shadowMultiplier    = max(shadowMultiplier, newShadowMultiplier);
         }

         // offset to the next layer
         stepIndex    += 1;
         currentLayerHeight    -= layerHeight;
         currentTextureCoords    += texStep;
         heightFromTexture    = tex2Dlod(_ParallaxMap, half4(currentTextureCoords,0,0)).r;  
      }

      // Shadowing factor should be 1 if there were no points under the surface
      if(numSamplesUnderSurface < 1)
      {
         shadowMultiplier = 1;
      }
      else
      {
         shadowMultiplier = pow( 1.0 - shadowMultiplier,5);
      }*/
   }
   return lerp(1,0, min(8,hitTime)/8.0);
}

void vert(inout appdata_full v,out Input o){
  UNITY_INITIALIZE_OUTPUT(Input, o);
            //      计算副切线
           
            float3 binormal=cross(normalize(v.normal),normalize(v.tangent.xyz))*v.tangent.w;
    //      构建变换矩阵，将位置坐标从模型空间转换到切线空间
            float3x3 rotation=float3x3(v.tangent.xyz,binormal,v.normal);
    //      或者使用内建方法
    //      TANGENT_SPACE_ROTATION;
    //      转换光源方向从模型空间到切线空间
            o.MainLightDir=  mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;
 
 }
void surf (Input IN, inout SurfaceOutput o) {
	half h = tex2D (_ParallaxMap, IN.uv_BumpMap).r;
	  fixed3 tangentLightDir=(IN.MainLightDir);

	//float2 offset = ParallaxOffsetModify (h, _Parallax, IN.viewDir);
	//float2 offset=(ParallaxUvDelta(IN)+ParallaxUvDelta2(IN))/2;
float	initialHeight;
	float2 offset =  _UseMain>0.5?  ParallaxUvDelta(IN,initialHeight):ParallaxUvDelta2(IN,initialHeight);
	 IN.uv_MainTex += offset;
	 IN.uv_BumpMap += offset;
	// tangentLightDir.xy*=-1;
		  float sm=1;
		  if(_Shadow)sm=parallaxSoftShadowMultiplier(tangentLightDir,IN.uv_MainTex,initialHeight);
	 // sm=1;
	fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
	o.Albedo = (c.rgb+0.2)/1.2*sm;
	o.Alpha = c.a;
	o.Normal = UnpackScaleNormal(tex2D(_BumpMap, IN.uv_BumpMap),1);
	//if(tangentLightDir.z==0)o.Albedo =0;
}

ENDCG

SubShader {
	Tags { "RenderType"="Opaque" }
	LOD 500

	CGPROGRAM
	#pragma surface surf Lambert  vertex:vert
	#pragma target 3.0
	ENDCG
}

 
}