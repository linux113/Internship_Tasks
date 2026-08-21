"use client";

import { useEffect, useRef } from "react";

const VERTEX = `
attribute vec2 position;
void main(){gl_Position=vec4(position,0.0,1.0);}`;

const FRAGMENT = `
precision mediump float;
uniform vec2 resolution;
uniform vec2 pointer;
uniform float time;
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
void main(){
  vec2 uv=gl_FragCoord.xy/resolution.xy;
  vec2 p=vec2(mix(.16,.84,pointer.x),-.12);
  vec2 delta=uv-p;
  delta.x*=resolution.x/resolution.y;
  float distanceToLight=length(delta);
  float bloom=exp(-distanceToLight*3.25);
  float columns=.55+.45*sin(uv.x*72.0+sin(uv.x*15.0-time*.07)*2.4);
  columns*=.72+.28*sin(uv.x*149.0-time*.035);
  float shaft=mix(1.0,smoothstep(-.15,.85,columns),.34)*smoothstep(.94,.12,uv.y);
  float breathe=.94+.06*sin(time*.28);
  float energy=clamp(bloom*shaft*breathe,0.0,1.0);
  vec3 background=vec3(.027,.067,.090);
  vec3 champagne=vec3(.79,.65,.41);
  vec3 hot=vec3(1.0,.88,.66);
  vec3 color=mix(background,champagne,energy*.55);
  color=mix(color,hot,pow(energy,3.0)*.5);
  float vignette=1.0-smoothstep(.45,.95,length(uv-.5));
  float grain=(hash(gl_FragCoord.xy+time)-.5)/255.0*2.0;
  gl_FragColor=vec4(color*(.76+.24*vignette)+grain,1.0);
}`;

function shader(gl: WebGLRenderingContext, type: number, source: string) {
  const value=gl.createShader(type); if(!value)return null;
  gl.shaderSource(value,source);gl.compileShader(value);
  if(!gl.getShaderParameter(value,gl.COMPILE_STATUS)){gl.deleteShader(value);return null;}
  return value;
}

export function LightBloom(){
  const canvas=useRef<HTMLCanvasElement>(null);
  useEffect(()=>{
    const node=canvas.current;if(!node)return;
    const gl=node.getContext("webgl",{alpha:false,antialias:false,powerPreference:"low-power"});if(!gl)return;
    const vs=shader(gl,gl.VERTEX_SHADER,VERTEX),fs=shader(gl,gl.FRAGMENT_SHADER,FRAGMENT);if(!vs||!fs)return;
    const program=gl.createProgram();if(!program)return;gl.attachShader(program,vs);gl.attachShader(program,fs);gl.linkProgram(program);gl.useProgram(program);
    const buffer=gl.createBuffer();gl.bindBuffer(gl.ARRAY_BUFFER,buffer);gl.bufferData(gl.ARRAY_BUFFER,new Float32Array([-1,-1,1,-1,-1,1,-1,1,1,-1,1,1]),gl.STATIC_DRAW);
    const pos=gl.getAttribLocation(program,"position");gl.enableVertexAttribArray(pos);gl.vertexAttribPointer(pos,2,gl.FLOAT,false,0,0);
    const resolution=gl.getUniformLocation(program,"resolution"),pointer=gl.getUniformLocation(program,"pointer"),time=gl.getUniformLocation(program,"time");
    let width=0,height=0,frame=0,last=0;const target={x:.72,y:.5},current={x:.72,y:.5};const reduced=matchMedia("(prefers-reduced-motion: reduce)").matches;
    const resize=()=>{const dpr=Math.min(devicePixelRatio,1.5);width=Math.max(1,Math.floor(node.clientWidth*dpr));height=Math.max(1,Math.floor(node.clientHeight*dpr));if(node.width!==width||node.height!==height){node.width=width;node.height=height;gl.viewport(0,0,width,height);}};
    const move=(event:PointerEvent)=>{target.x=event.clientX/innerWidth;target.y=event.clientY/innerHeight;};
    const render=(now:number)=>{resize();current.x+=(target.x-current.x)*.035;current.y+=(target.y-current.y)*.035;gl.uniform2f(resolution,width,height);gl.uniform2f(pointer,current.x,current.y);gl.uniform1f(time,reduced?0:now/1000);gl.drawArrays(gl.TRIANGLES,0,6);if(!reduced&&now-last>=30){last=now;}if(!reduced)frame=requestAnimationFrame(render);};
    addEventListener("pointermove",move,{passive:true});frame=requestAnimationFrame(render);
    return()=>{cancelAnimationFrame(frame);removeEventListener("pointermove",move);gl.deleteProgram(program);gl.deleteShader(vs);gl.deleteShader(fs);gl.deleteBuffer(buffer);};
  },[]);
  return <canvas ref={canvas} className="pointer-events-none absolute inset-0 h-full w-full opacity-55" aria-hidden/>;
}
