Absolutely! Here's a **detailed `README.md` file** tailored specifically to your task — including:

* What you captured.
* How to open the `.pcapng` file in Wireshark.
* What credentials were found (example).
* Clear steps and explanations written professionally for your GitHub project.

---

### ✅ Final `README.md` Content (You Can Copy-Paste into Your GitHub Repo)

```markdown
# Sniffing Attack on HTTP using Wireshark

## 📌 Objective

This project demonstrates how to perform a **sniffing attack** on a vulnerable website using **Wireshark**, with the goal of capturing **HTTP login credentials** (username and password) transmitted over an **unencrypted connection**.

The vulnerable test website used is:

**🔗 http://testphp.vulnweb.com**

---

## 🧪 What Was Captured

Using Wireshark, I captured unencrypted HTTP traffic between my browser and the target website. During this process, I submitted a test login form containing a username and password. This data was captured in the form of HTTP **POST** requests.

The captured traffic was saved in a file called:

**`sniffing_task.pcapng`**

---

## 📂 How to Open the `.pcapng` File in Wireshark

Follow these steps to analyze the capture:

1. **Open Wireshark** on your computer.
2. Go to the **File** menu → **Open...**
3. Select the file: `sniffing_task.pcapng`
4. In the top filter bar, enter:
```

http.request.method == "POST"

```
This filter will show only POST requests, which usually contain form submissions.
5. Click on a packet in the filtered list.
6. In the **Packet Details** pane (middle section), expand the line labeled:
```

Hypertext Transfer Protocol

```
7. Look for a section like:
```

Form item: username = kali
Form item: password = kali

```
These are the captured login credentials in plain text.

---

## 🔍 Credentials Found

From analyzing the captured HTTP POST packet, the following test credentials were found:

- **Username**: `kali`
- **Password**: `kali`

This proves that **HTTP (without SSL/TLS)** does **not** encrypt user data, making it vulnerable to interception.

---

## ⚠️ Security Warning

This demonstration shows how insecure HTTP can be for sensitive data. **Modern websites use HTTPS to prevent this type of attack.** Never send credentials over unencrypted HTTP in real-world applications.

---

## 🛠 Tools Used

- **Wireshark**: Network packet analyzer ([https://www.wireshark.org/](https://www.wireshark.org/))
- **Test Site**: [http://testphp.vulnweb.com](http://testphp.vulnweb.com) — a legal, purposely vulnerable site for testing and education.

---

## 📁 Repository Structure

```

📦 wireshark-sniffing-task/
├── sniffing\_task.pcapng     # Wireshark capture file
└── README.md                # Explanation of the task and findings

```

---

## 🧠 Educational Purpose

This project is created strictly for **educational and ethical hacking training**. The actions demonstrated were performed on a known test environment with no risk to real users or systems.
