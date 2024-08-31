from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates

from lib.utils import get_short_commit_hash

templates = Jinja2Templates(directory="templates")
app = FastAPI()


@app.get("/")
def landing(request: Request) -> HTMLResponse:
    github_commit_hash = get_short_commit_hash()
    return templates.TemplateResponse(
        request=request, name="base.html", context={"commit_hash": github_commit_hash}
    )
