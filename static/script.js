async function generateLog() {
    const response = await fetch('/newLog', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        }
    });

    if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
    }
    const result = await response.json();
    console.log('Python function returned:', result.timestamp, result.value);
    let element = document.getElementById("latestLog");
    element.textContent = JSON.stringify(result);
}

async function processLogs() {
    fetch('/processLogs', { method: 'POST' })
        .then(response => response.json())
        .then(data => {
            document.getElementById("mlResponse").innerText =
                `Anomalies detected:\n${JSON.stringify(data, null, 2)}`
        });
}