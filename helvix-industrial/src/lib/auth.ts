import { SignJWT, jwtVerify } from "jose";
import { cookies } from "next/headers";
import bcrypt from "bcryptjs";
import { prisma } from "./prisma";

export type SessionUser = {
  id: string;
  name: string;
  email: string;
  role: string;
};

export const SESSION_COOKIE = "helvix_session";

function secret() {
  return new TextEncoder().encode(
    process.env.AUTH_SECRET || "helvix-dev-secret-change-me",
  );
}

export async function hashPassword(password: string) {
  return bcrypt.hashSync(password, 12);
}

export async function verifyPassword(password: string, hash: string) {
  if (!password || !hash) return false;
  return bcrypt.compareSync(password, hash);
}

export const SESSION_COOKIE_OPTIONS = {
  httpOnly: true,
  sameSite: "lax" as const,
  secure: process.env.NODE_ENV === "production",
  path: "/",
  maxAge: 60 * 60 * 24 * 7,
};

export async function signSession(user: SessionUser) {
  return new SignJWT(user)
    .setProtectedHeader({ alg: "HS256" })
    .setIssuedAt()
    .setExpirationTime("7d")
    .sign(secret());
}

export async function createSession(user: SessionUser) {
  const token = await signSession(user);
  const jar = await cookies();
  jar.set(SESSION_COOKIE, token, SESSION_COOKIE_OPTIONS);
  return token;
}

export async function destroySession() {
  const jar = await cookies();
  jar.delete(SESSION_COOKIE);
}

export async function getSession(): Promise<SessionUser | null> {
  const jar = await cookies();
  const token = jar.get(SESSION_COOKIE)?.value;
  if (!token) return null;
  try {
    const { payload } = await jwtVerify(token, secret());
    return {
      id: String(payload.id),
      name: String(payload.name),
      email: String(payload.email),
      role: String(payload.role),
    };
  } catch {
    return null;
  }
}

export async function requireSession() {
  const session = await getSession();
  if (!session) return null;
  const user = await prisma.user.findUnique({ where: { id: session.id } });
  if (!user || user.active === false) return null;
  return {
    id: user.id,
    name: user.name,
    email: user.email,
    role: user.role,
  } satisfies SessionUser;
}

export { ROLE_LABELS, canAccess } from "./roles";
