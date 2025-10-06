#!/usr/bin/env bash
export PYTHONUNBUFFERED=1
uvicorn app.main:app --reload

