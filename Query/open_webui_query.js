/**
 * Fetch requests from Open WebUI
 */
const url = 'http://localhost:3000/api/chat/completions';
const apiKey = process.env.OPENWEBUI_API_KEY;

// Creates a request body with a model and message.
const requestBody = {
    // model: 'llama3.2:3b',
    model: 'mistral',
    messages: [
        {
            role: 'user',
            content: 'Is it Friday yet?'
        }
    ]
};

async function sendRequest() {
    try {
        // Sends a POST request to the API with the request body.
        const response = await fetch(url, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${apiKey}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(requestBody)
        });

        // Checks if the response is OK (200-299).
        if (!response.ok) {
            throw new Error(`Server error: ${response.status}`);
        }

        // Parses the response as JSON.
        const data = await response.json();
        // console.log(data);

        // Extracts the response content from the parsed data.
        const content = data.choices[0]?.message?.content;
        if (content) {
            console.log('Response:', content);
        } else {
            console.log('Unexpected response format:', data);
        }
    } catch (error) {
        console.error('Request failed:', error);
    }
}

sendRequest();
