from fastapi.responses import JSONResponse

class CustomJSONResponse(JSONResponse):
    def __init__(self, content, status_code=200, **kwargs):
        kwargs["media_type"] = "application/json; charset=utf-8"
        super().__init__(content=content, status_code=status_code, **kwargs)