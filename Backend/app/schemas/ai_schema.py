from pydantic import BaseModel


class Categorize(BaseModel):
    name: str

    class Config:
        from_attributes = True

class Train(BaseModel):
    name: str
    category: str

    class Config:
        from_attributes = True
