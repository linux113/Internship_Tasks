import { SignJWT, jwtVerify } from "jose";
export const COOKIE="sriyaan_admin";
const key=()=>new TextEncoder().encode(process.env.AUTH_SECRET||"development-only-change-before-production");
export async function signAdmin(email:string){return new SignJWT({email,role:"ADMIN"}).setProtectedHeader({alg:"HS256"}).setIssuedAt().setExpirationTime("8h").sign(key());}
export async function verifyAdmin(token:string){try{return (await jwtVerify(token,key())).payload;}catch{return null;}}
