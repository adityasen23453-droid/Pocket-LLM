import urllib.request
import json
import time

def run_e2e_verification():
    print("=" * 60)
    print("      POCKETLLM END-TO-END AUTOMATED VERIFICATION")
    print("=" * 60)

    # 1. Health check
    print("\n[Step 1] Checking Backend Health on http://127.0.0.1:8000/api/health...")
    health_url = "http://127.0.0.1:8000/api/health"
    with urllib.request.urlopen(health_url, timeout=5) as resp:
        health = json.loads(resp.read().decode("utf-8"))
    print(f"  Status: {health['status']}")
    print(f"  Hardware Device: {health['device'].upper()}")
    print(f"  Model ID: {health['model']}")
    print(f"  Active ChromaDB Chunks: {health['rag_chunks_indexed']}")
    assert health["status"] == "online", "Backend must be online"
    assert health["device"] == "cuda", "Backend must run on CUDA GPU"

    # 2. Upload sample physics notes
    print("\n[Step 2] Uploading NCERT/CBSE Ray Optics Note to RAG Vector Store...")
    boundary = "----WebKitFormBoundary7MA4YWxkTrZu0gW"
    notes_content = (
        "Ray Optics - Total Internal Reflection (TIR):\n"
        "1. Light must travel from an optically denser medium to an optically rarer medium.\n"
        "2. The angle of incidence in the denser medium must be greater than the critical angle (i > c).\n"
        "Formula: sin(c) = 1 / mu, where mu is refractive index of denser medium relative to rarer medium.\n"
        "Applications: Optical fibres, mirage formation in deserts, and brilliance of diamonds."
    )
    
    parts = [
        f"--{boundary}\r\n"
        f'Content-Disposition: form-data; name="file"; filename="cbse_optics_notes.txt"\r\n'
        f"Content-Type: text/plain\r\n\r\n"
        f"{notes_content}\r\n"
        f"--{boundary}--\r\n"
    ]
    body = "".join(parts).encode("utf-8")

    upload_req = urllib.request.Request(
        "http://127.0.0.1:8000/api/upload",
        data=body,
        headers={"Content-Type": f"multipart/form-data; boundary={boundary}"}
    )
    with urllib.request.urlopen(upload_req, timeout=10) as resp:
        upload_res = json.loads(resp.read().decode("utf-8"))
    print(f"  Upload Success: {upload_res['success']}")
    print(f"  Chunks Added: {upload_res['chunks_added']}")
    print(f"  Total Chunks in DB: {upload_res['total_chunks_in_db']}")
    assert upload_res["success"] is True

    # 3. Stream chat query with RAG grounding
    print("\n[Step 3] Querying: 'What are the two conditions for Total Internal Reflection?'")
    print("  Streaming tokens in real time from local Qwen 2.5 on CUDA:")
    print("  " + "-" * 50)
    
    chat_payload = {
        "message": "What are the two conditions for Total Internal Reflection according to my notes?",
        "use_rag": True,
        "top_k": 2
    }
    chat_req = urllib.request.Request(
        "http://127.0.0.1:8000/api/chat",
        data=json.dumps(chat_payload).encode("utf-8"),
        headers={"Content-Type": "application/json"}
    )

    tokens = []
    sources = []
    with urllib.request.urlopen(chat_req, timeout=30) as resp:
        for line in resp:
            line_str = line.decode("utf-8").strip()
            if line_str.startswith("data: "):
                data = json.loads(line_str[6:])
                if data.get("type") == "sources":
                    sources = data["sources"]
                    print(f"\n  [RAG Citation Event]: Grounded in {sources}")
                elif data.get("type") == "token":
                    content = data["content"]
                    tokens.append(content)
                    print(content, end="", flush=True)

    print("\n  " + "-" * 50)
    full_text = "".join(tokens)
    print(f"\n[Step 4] Received {len(tokens)} tokens successfully!")
    assert len(tokens) > 5, "Must receive multiple streamed tokens"
    assert "cbse_optics_notes.txt" in sources, "Must cite uploaded note"
    assert "denser" in full_text.lower() or "critical angle" in full_text.lower()

    print("\n" + "=" * 60)
    print("  >>> ALL END-TO-END TESTS PASSED WITH 100% SUCCESS! <<<")
    print("=" * 60)

if __name__ == "__main__":
    run_e2e_verification()

