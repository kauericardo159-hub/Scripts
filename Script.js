(function() {
    const styleId = 'gemini-custom-style';
    if (document.getElementById(styleId)) return;

    const css = `
        /* Estiliza o balão do usuário */
        .user-query-container, [data-test-id="user-query"] {
            display: flex !important;
            flex-direction: row-reverse !important;
            align-items: flex-start !important;
            gap: 15px !important;
            background: #f0f4f9 !important; /* Cor suave */
            border-radius: 25px !important;
            padding: 15px !important;
            margin: 10px 0 !important;
        }

        /* Tenta forçar a foto de perfil do Google no lado */
        .user-query-container img, .user-avatar {
            width: 45px !important;
            height: 45px !important;
            border-radius: 50% !important;
            order: 2 !important; /* Joga a foto para a direita ou esquerda conforme desejar */
            border: 2px solid #4285f4 !important;
        }

        /* Estiliza o balão do Gemini */
        .model-response-container {
            background: #ffffff !important;
            border: 1px solid #dee2e6 !important;
            border-radius: 20px !important;
            padding: 20px !important;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05) !important;
        }
    `;

    const styleSheet = document.createElement("style");
    styleSheet.id = styleId;
    styleSheet.innerText = css;
    document.head.appendChild(styleSheet);
    
    console.log("Visual do Gemini atualizado! ✨");
})();
