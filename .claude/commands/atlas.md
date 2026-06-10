---
description: יוצר/מעדכן CODEATLAS.md — מפת קשרים וניווט של הפרויקט (איך הכל מתחבר)
---

צור (או עדכן אם קיים) קובץ בשם `CODEATLAS.md` בשורש הפרויקט — מפת ניווט וקשרים מלאה של הפרויקט הנוכחי.

לפני הכתיבה, סרוק את הפרויקט לעומק: נקודת הכניסה, הראוטים, ה-stores, שכבת הנתונים, שירותים חיצוניים (Firebase / API / DB), ותלויות בין קבצים. אל תמציא — תעד רק מה שקיים בפועל בקוד.

## פורמט הקובץ

הכותרת והפתיח:

```markdown
# CODEATLAS.md - <ProjectName> Navigation Map

> How to find anything. How everything connects.
> Follow the arrows. Follow the data.
```

הסעיפים (התאם לפי מה שרלוונטי לפרויקט — דלג על סעיף שלא קיים בו תוכן אמיתי):

1. **How to Read This Atlas** — דיאגרמת ASCII קצרה של זרימת הנתונים הכללית, למשל:
   `Component ──calls──▶ Hook ──calls──▶ Service ──calls──▶ Data Layer ──queries──▶ DB`
2. **Boot Sequence** — מה קורה כשהאפליקציה עולה, כעץ ASCII מ-entry point פנימה, כולל providers, אתחול חיבורים וכו'.
3. **Route Map** — כל המסכים/נתיבים, מקובצים לפי הרשאה (public / user / admin...), כל נתיב עם הקומפוננטה שלו.
4. **Navigation Structure** — ה-shell, תפריטים, layouts.
5. **Core Flows** — סעיף לכל תהליך מרכזי במערכת (lifecycle של הישות המרכזית, תהליכי AI, תהליכי אישור וכו'), כתרשים ASCII של הצעדים: מי קורא למי, אילו קבצים מעורבים, מה נכתב לאן.
6. **State Management Map** — כל ה-stores / contexts / query caches / מפתחות localStorage.
7. **Data Flow Patterns** — הדפוסים החוזרים בקוד (Component→Service→DB וכו') עם דוגמה אמיתית לכל דפוס.
8. **Database Map** — כל הטבלאות/אוספים: מי כותב, מי קורא, אילו אינדקסים.
9. **Backend Map** — Cloud Functions / API endpoints: טריגר, קלט, פלט.
10. **File Dependency Map** — שכבת היסוד שכולם תלויים בה, הקבצים ה"רכזות" (hubs) שהכי הרבה מייבאים מהם.
11. **Domain Boundaries** — גבולות בין מודולים: מה מותר לייבא ממה.
12. **Quick Lookup - "Where Do I Find...?"** — טבלה בסוף: "אני רוצה לשנות X" → הקובץ/פונקציה המדויקים. לפחות 15–25 שורות של המשימות הנפוצות ביותר.

## כללים

- כתוב באנגלית (כמו קוד), עם תרשימי ASCII עם חצים (`──▶`, `└─▶`) — לא Mermaid.
- כל נתיב קובץ חייב להיות אמיתי ומדויק (`src/...`), כך שאפשר ללחוץ/לחפש אותו.
- אם `CODEATLAS.md` כבר קיים — עדכן אותו במקום: הוסף סעיפים לפיצ'רים חדשים, תקן נתיבים שהשתנו, מחק מה שנמחק מהקוד.
- בסיום, ודא שכל קובץ שמוזכר אכן קיים (בדוק מדגמית עם glob/grep).
