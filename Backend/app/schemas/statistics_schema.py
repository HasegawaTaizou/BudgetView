from pydantic import BaseModel
from typing import List

class CategoryStatistics(BaseModel):
    category_name: str
    total: float
    percentage: str

class StatisticsResponse(BaseModel):
    total_spend: float
    total_earn: float
    earn_statistics: List[CategoryStatistics]
    spend_statistics: List[CategoryStatistics]
