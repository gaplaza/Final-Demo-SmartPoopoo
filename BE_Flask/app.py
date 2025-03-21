from flask import Flask, jsonify, request
import torch
import numpy as np
from skimage import io
from PIL import Image
import base64

import img_func
import gpt_model


app = Flask(__name__)

# 메모리상에 대화 기록을 저장하는 딕셔너리 (세션별로 기록)
conversations = {}


#     아기 똥   
 
# 건강 상태 분석
@app.route('/smartpoopoo', methods=['POST'])
def smartpoopoo():
    try:
        # Base64 형식으로 이미지 전달 받음
        data = request.get_json()
        base64_image = data['image']

        # Base64를 디코딩하여 이미지로 변환
        image_data = base64.b64decode(base64_image)
        image = Image.open(io.BytesIO(image_data))

        # 이미지 전처리
        input_img = img_func.img_preprocess(image)
        
        # smart model 호출
        first_answer = gpt_model.start(input_img, conversations)
        
        if not first_answer:
            # 재촬영 필요
            return jsonify({'error': '똥이 없어요'}), 400
        
        else :
            return jsonify(first_answer), 200
    # 오류 발생 시
    except Exception as e:
        return jsonify({"error": str(e)}), 500

    
    
#     임신 테스트기    

# # 임신 테스트기 분류
# @app.route('/upload_tester', methods=['POST'])
# def upload_tester():
#     try:
#         data = request.get_json()
#         base64_image = data['image']

#         # Base64를 디코딩하여 이미지로 변환
#         image_data = base64.b64decode(base64_image)
#         image = Image.open(io.BytesIO(image_data))

#         input_img = img_func.img_preprocess(image)
#         tester_result = tester_model(input_img)
#
#         # 예시로 응답 반환
#         return jsonify({'image' : detected_tester, 'result' : result}), 200
#     except Exception as e:
#         return jsonify({"error": str(e)}), 500



#     ChatGPT     

# 추가 질문
@app.route('/ask', methods=['POST'])
def ask():
    
    # 세션 ID와 추가 질문을 음성으로 받아옴
    data = request.form
    session_id, question = data.get("session_id", "question")

    if not session_id or session_id not in conversations:
            return jsonify({"error": "Invalid or missing session_id"}), 400
        
    if not question:
             return jsonify({"error": "No qeustion provided"}), 400

    # 대화 기록에 추가 질문을 저장
    conversations[session_id].append({"role": "user", "content": question})

    # GPT-4 호출하여 추가 질문에 대한 답변을 받음
    try:
        response = gpt_model.call_gpt4o(conversations[session_id])
        # GPT의 답변을 대화 기록에 추가
        conversations[session_id].append({"role": "assistant", "content" : response})
        
        return jsonify({"response": response})
    
    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == '__main__':
    app.run(debug=True)