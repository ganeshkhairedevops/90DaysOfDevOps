# Day 38 – YAML Basics

Today I learned the fundamentals of YAML syntax, structure, and validation.

---

# Task 1 – Key-Value Pairs

Created person.yaml with simple key-value structure.

Key points:
- YAML uses `key: value` format
- No tabs allowed
- Spaces only (2-space indentation standard)

![task 1](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/71dd58fba89563b126dba81d4af181ecec90a489/2026/day-38/images/task%201.JPG)

---

# Task 2 – Lists

Two ways to write lists:

1. Block style:
   tools:
     - docker
     - docker compose

2. Inline style:
   hobbies: [Problem Solving, Coding]

Block style is preferred for readability.

![task2](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/71dd58fba89563b126dba81d4af181ecec90a489/2026/day-38/images/task%202.JPG)

---

# Task 3 – Nested Objects

Created nested structure in server.yaml.

Important rule:
Indentation defines hierarchy.

Example:
database:
  credentials:
    user: appuser

If indentation is wrong → YAML parsing fails.

---

# Task 4 – Multi-line Strings

Used:

| (Pipe) – Preserves newlines exactly  
> (Fold) – Folds lines into single paragraph

When to use:

| → Shell scripts, configs, code blocks  
> → Long descriptions
---

# Task 5 – Validation

Used yamllint to validate files.
Key points:
- Checks syntax and formatting
- Ensures consistent indentation
- Catches common errors
Validation is crucial to prevent runtime errors in applications that rely on YAML configs.

1:1 warning missing document start "---" (document-start)

our YAML file is valid, but it’s missing the document start marker ---

update yaml files

![person](https://github.com/ganeshkhairedevops/90DaysOfDevOps/blob/71dd58fba89563b126dba81d4af181ecec90a489/2026/day-38/images/task%205.JPG)

---

# Task 6 – Spot the Difference

Correct block:

tools:
  - docker
  - kubernetes

Broken block:

tools:
- docker
  - kubernetes

Problem:
Inconsistent indentation. YAML expects list items aligned properly under the key.

---

# 3 Key Learnings
1. Proper indentation is crucial in YAML to define structure and hierarchy.
2. YAML supports both block and inline styles for lists, with block style being more readable.
3. Validation tools like yamllint are essential to catch syntax errors and ensure YAML files are correctly formatted before use.
---

# Conclusion
YAML is a powerful and human-readable format for configuration files. Understanding its syntax and structure is essential for effective use in DevOps and software development. Proper indentation, consistent formatting, and validation are key to creating reliable YAML files that can be used in various applications.