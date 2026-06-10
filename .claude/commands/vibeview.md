---
description: יוצר/מעדכן VIBEVIEW.md — מפת טבלאות של כל קבצי הפרויקט עם שם קונספטואלי לכל קובץ
---

צור (או עדכן אם קיים) קובץ בשם `VIBEVIEW.md` בשורש הפרויקט — "הפרויקט במבט אחד": כל קובץ בפרויקט מוסבר בטבלאות, עם **שם קונספטואלי** לכל קובץ — מה הוא *באמת*, לא רק איך קוראים לו.

לפני הכתיבה, עבור על עץ הקבצים המלא של הפרויקט (ללא node_modules / build outputs) וקרא מספיק מכל קובץ כדי לתת לו שם ותיאור מדויקים. אל תמציא — תעד רק מה שקיים.

## פורמט הקובץ

הכותרת והפתיח:

```markdown
# VIBEVIEW.md - <ProjectName> at a Glance

> Every file in the project, explained like you're reading a map.
> Each file gets a **conceptual name** - what it *is*, not what it's called.
```

ואז:

1. **What is <ProjectName>?** — פסקה קצרה: מה האפליקציה עושה, למי, ושורת Stack אחת:
   `**Stack:** React + TypeScript | Firebase | ...`
2. סעיף לכל תיקייה, מהשורש פנימה (Root, `.claude/`, `.github/`, `public/`, `src/` על תתי-התיקיות שלו...), כל סעיף עם כותרת + כינוי:
   `## Root - The Foundation`, `## src/lib/firebase/ - The Data Layer`
3. בכל סעיף — טבלה בפורמט הקבוע:

```markdown
| File | Conceptual Name | What it does |
|------|----------------|-------------|
| `package.json` | **The Blueprint** | All dependencies, scripts, and project metadata. |
| `firestore.rules` | **The Bouncer** | Security rules - who can read/write which collections. |
```

4. אם יש מסד נתונים — סעיף אחרון עם טבלת האוספים/טבלאות:

```markdown
| Collection | Conceptual Name | What it holds |
|------------|----------------|---------------|
| `users` | **The User Registry** | Profiles, roles, settings. |
```

## כללים

- כתוב באנגלית. השמות הקונספטואליים צריכים להיות זכירים ומדויקים ("The Bouncer", "The History Book", "The Ignition") — שם אחד לכל קובץ, מודגש.
- כל קובץ אמיתי בפרויקט חייב להופיע; אל תכלול קבצים שלא קיימים.
- שורת התיאור קצרה (שורה אחת-שתיים), אבל ספציפית — מה הקובץ עושה בפרויקט *הזה*, לא הגדרה גנרית.
- אם `VIBEVIEW.md` כבר קיים — עדכן אותו: הוסף שורות לקבצים חדשים, מחק שורות של קבצים שנמחקו, עדכן תיאורים שהשתנו.
