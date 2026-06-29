def credibility_score(critic_result: dict, citations: int = 0) -> float:
    """امتیاز اعتبار بر اساس تعداد نقاط ضعف و تعداد استنادها"""
    weaknesses_count = len(critic_result.get("weaknesses", []))
    score = max(0, 100 - weaknesses_count * 8)
    # استنادها تأثیر مثبت دارند (حداکثر +20)
    citation_bonus = min(20, citations // 5)
    score = min(100, score + citation_bonus)
    return score
