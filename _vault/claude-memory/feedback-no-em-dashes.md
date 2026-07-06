---
name: No em dashes in any writing
description: Standing rule. Eliminate em dashes (—, U+2014) from all writing for Jim — documents, emails, code comments, chat, every output.
type: feedback
originSessionId: a11d6405-8665-4cf7-8ef5-b2e58f9b65a7
---
Never use em dashes (—) in any output for Jim. Documents, emails, code comments, chat replies, generated content. All of it.

**Why:** Jim flagged em dashes as a tell of AI-generated writing (2026-05-04). They make documents feel less authentic and more synthetic. He cares because his customer-facing docs (estimates, contractor agreements, sales emails, ad copy) need to read as written by a human operator, not a model.

**How to apply:**
- Replace em dashes with one of: period + new sentence, colon, comma, parentheses, or "and"/"with" depending on the rhetorical role the em dash was playing
- Choose the substitute that preserves the rhythm and clarity of the sentence
- This applies to BOTH content I write directly (markdown, code comments, chat) AND content I generate via tools (PDFs, emails, ad copy, page copy, scripts)
- En dashes (–, U+2013) are also suspect AI-tells when used decoratively; only keep en dashes for genuine ranges (e.g., "2025–2026") and replace decorative en dashes with the same substitutes
- Hyphens (-) are fine — they're for compound words (two-coat, pressure-treated) and not in scope of this rule
- When auditing existing content, grep/search for U+2014 explicitly: `—` is NOT the same character as `-`
