# parallax
各种视差算法对比<br>
视差映射（Parallax Mapping），带偏移上限的视差映射（Parallax Mapping with Offset Limiting），陡峭视差映射（Steep Parallax Mapping），浮雕视差映射（Relief Parallax Mapping）和视差遮蔽映射(Parallax Occlusion Mapping） <br>

 精度对比结果<br>
 为了更直观的对比 各种 视差算法的精确度差距 做成了对比图形 谁与蓝色小球 （真实交点）越接近 就越精确，绿色最弱 是unity自带的普通视差 黄色好些 是陡峭视差（5次分成采样），确实 青色的 pom (5次分成采样）在这些高性能里算不错的 ，Relief版没实现 因为性能不考虑,紫色是自己脑洞实现的算法 没查到名字 模拟ssr里raymaching 来求交为了公平 也5次分成采样
 
![精度对比图](/ReadMeFiles/parallax.gif)<br>
