export DJANGO_SECRET_KEY='123'
py.test elvanto_sync --reuse-db --cov="elvanto_sync/" --cov-report="term-missing" --flakes --isort --pep8
