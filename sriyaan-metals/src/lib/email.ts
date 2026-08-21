import nodemailer from "nodemailer";

export type EnquiryNotification = {
  type: string;
  name: string;
  company?: string;
  email: string;
  phone?: string;
  country?: string;
  product?: string;
  quantity?: string;
  message: string;
};

function configured() {
  return Boolean(process.env.SMTP_HOST && process.env.SMTP_USER && process.env.SMTP_PASSWORD);
}

export async function sendEnquiryNotification(data: EnquiryNotification) {
  if (!configured()) {
    if (process.env.NODE_ENV !== "production") {
      console.info("SMTP not configured; enquiry was saved without an email notification.");
    }
    return { sent: false };
  }

  const transport = nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: Number(process.env.SMTP_PORT || 587),
    secure: Number(process.env.SMTP_PORT || 587) === 465,
    auth: { user: process.env.SMTP_USER, pass: process.env.SMTP_PASSWORD },
  });
  const destination = data.type === "vendor"
    ? "purchase@sriyaanmetals.co"
    : "sales@sriyaanmetals.co";
  const lines = [
    `Type: ${data.type}`,
    `Name: ${data.name}`,
    `Company: ${data.company || "—"}`,
    `Email: ${data.email}`,
    `Phone: ${data.phone || "—"}`,
    `Country: ${data.country || "—"}`,
    `Product: ${data.product || "—"}`,
    `Quantity: ${data.quantity || "—"}`,
    "",
    data.message,
  ];
  await transport.sendMail({
    from: process.env.SMTP_FROM || "SRIYAAN METALS <info@sriyaanmetals.co>",
    to: destination,
    replyTo: data.email,
    subject: `[SRIYAAN METALS] New ${data.type} enquiry from ${data.name}`,
    text: lines.join("\n"),
  });
  return { sent: true };
}
