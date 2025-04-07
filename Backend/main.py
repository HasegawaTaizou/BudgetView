from fastapi import FastAPI

from app.utils.custom_json_response import CustomJSONResponse

import app.database.init_db

from app.controllers.type_controller import router as type_router
from app.controllers.icon_controller import router as icon_router
from app.controllers.category_controller import router as category_router
from app.controllers.transaction_controller import router as transaction_router
from app.controllers.statistics_controller import router as statistics_router
from app.controllers.ai_controller import router as ai_router


app = FastAPI(
    title="BudgetView API",
    description="API para gerenciamento de categorias, transações e estatísticas com IA.",
    version="1.0.0",
    contact={
        "name": "Hasegawa Taizou",
        "url": "https://github.com/hasegawataizou",
    },
    license_info={
        "name": "MIT License",
        "url": "https://opensource.org/licenses/MIT",
    },
    default_response_class=CustomJSONResponse,
)

app.include_router(type_router, tags=["Tipos"])
app.include_router(icon_router, tags=["Ícones"])
app.include_router(category_router, tags=["Categorias"])
app.include_router(transaction_router, tags=["Transações"])
app.include_router(statistics_router, tags=["Estatísticas"])
app.include_router(ai_router, tags=["Inteligência Artificial"])

