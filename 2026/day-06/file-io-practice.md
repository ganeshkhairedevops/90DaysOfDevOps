# Day 06 – File Read & Write Practice

Basic file input/output in Linux using simple commands.
Creating, writing, appending, and reading text files.

---

## 1️⃣ Create a file

Command:
touch notes.txt

What it did:
- Created an empty file named notes.txt

---

## 2️⃣ Write text to the file

Command:
echo "This is line 1" > notes.txt

What it did:
- Wrote first line into the file
- Overwrites file if it already exists

---

## 3️⃣ Append new lines

Command:
echo "This is line 2" >> notes.txt

What it did:
- Appended a second line to the file

Command:
echo "This is line 3" | tee -a notes.txt

What it did:
- Displayed the line on screen
- Appended the line to notes.txt

---

## 4️⃣ Read the file

Command:
cat notes.txt

What it did:
- Displayed the full contents of the file

---

## 5️⃣ Read part of the file

Command:
head -n 2 notes.txt

What it did:
- Showed first 2 lines of the file

Command:
tail -n 2 notes.txt

What it did:
- Showed last 2 lines of the file

---

## 📸 Command Output Screenshot
[File IO Practice](./2026/day-06/day-06.JPG)
![File IO Practice Output](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/49df5bca599c5de1359826098a88fb35b2751656/2026/day-06/day-06.JPG)



