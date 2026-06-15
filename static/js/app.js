// WebPortal Application

let links = [];
let draggedElement = null;
let deletingIndex = null;

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    loadLinks();
    setupEventListeners();
});

// Event Listeners
function setupEventListeners() {
    document.getElementById('addBtn').addEventListener('click', openLinkModal);
    document.getElementById('settingsBtn').addEventListener('click', openSettingsModal);
    
    // Close modals when clicking outside
    window.addEventListener('click', (event) => {
        const linkModal = document.getElementById('linkModal');
        const settingsModal = document.getElementById('settingsModal');
        const confirmModal = document.getElementById('confirmModal');
        
        if (event.target === linkModal) {
            closeLinkModal();
        }
        if (event.target === settingsModal) {
            closeSettingsModal();
        }
        if (event.target === confirmModal) {
            cancelDelete();
        }
    });
}

// Load Links
async function loadLinks() {
    try {
        const response = await fetch('/api/links');
        links = await response.json();
        renderLinks();
    } catch (error) {
        console.error('Error loading links:', error);
        showToast('Error loading links', 'error');
    }
}

// Render Links
function renderLinks() {
    const container = document.getElementById('linksContainer');
    const emptyState = document.getElementById('emptyState');
    
    container.innerHTML = '';
    
    if (links.length === 0) {
        emptyState.style.display = 'block';
        return;
    }
    
    emptyState.style.display = 'none';
    
    links.forEach((link, index) => {
        const card = createLinkCard(link, index);
        container.appendChild(card);
    });
}

// Create Link Card
function createLinkCard(link, index) {
    const card = document.createElement('div');
    card.className = 'link-card';
    card.draggable = true;
    card.dataset.index = index;
    
    // Set border color based on link color
    card.style.borderLeftColor = link.color || '#3498DB';
    
    const categoryHtml = link.category ? `<span class="link-card-category">${escapeHtml(link.category)}</span>` : '';
    const descriptionHtml = link.description ? `<p class="link-card-description">${escapeHtml(link.description)}</p>` : '';
    
    card.innerHTML = `
        <div class="link-card-header">
            <h3 class="link-card-title">${escapeHtml(link.title)}</h3>
            <button class="link-card-delete" onclick="confirmDeleteLink(${index})">Delete</button>
        </div>
        ${categoryHtml}
        ${descriptionHtml}
        <div class="link-card-url">${escapeHtml(link.url)}</div>
        <a href="${escapeHtmlAttr(link.url)}" target="_blank" rel="noopener noreferrer" class="link-card-link">Open Link →</a>
    `;
    
    // Drag events
    card.addEventListener('dragstart', handleDragStart);
    card.addEventListener('dragend', handleDragEnd);
    card.addEventListener('dragover', handleDragOver);
    card.addEventListener('drop', handleDrop);
    
    return card;
}

// Drag and Drop
function handleDragStart(e) {
    draggedElement = this;
    this.classList.add('dragging');
    e.dataTransfer.effectAllowed = 'move';
}

function handleDragEnd(e) {
    this.classList.remove('dragging');
    draggedElement = null;
}

function handleDragOver(e) {
    if (e.preventDefault) {
        e.preventDefault();
    }
    e.dataTransfer.dropEffect = 'move';
    return false;
}

function handleDrop(e) {
    if (e.stopPropagation) {
        e.stopPropagation();
    }
    
    if (draggedElement !== this && draggedElement.classList.contains('link-card')) {
        const draggedIndex = parseInt(draggedElement.dataset.index);
        const targetIndex = parseInt(this.dataset.index);
        
        // Swap items
        [links[draggedIndex], links[targetIndex]] = [links[targetIndex], links[draggedIndex]];
        
        // Update order field
        links.forEach((link, i) => {
            link.order = i;
        });
        
        // Save and re-render
        saveLinksOrder();
        renderLinks();
    }
    
    return false;
}

// Link Modal
function openLinkModal() {
    document.getElementById('linkModal').classList.add('show');
    document.getElementById('linkForm').reset();
    document.getElementById('modalTitle').textContent = 'Add Link';
    document.getElementById('linkColor').value = '#3498DB';
}

function closeLinkModal() {
    document.getElementById('linkModal').classList.remove('show');
    document.getElementById('linkForm').reset();
}

function submitLinkForm(event) {
    event.preventDefault();
    
    const link = {
        title: document.getElementById('linkTitle').value,
        url: document.getElementById('linkUrl').value,
        description: document.getElementById('linkDescription').value,
        category: document.getElementById('linkCategory').value || 'Other',
        color: document.getElementById('linkColor').value
    };
    
    addLink(link);
    closeLinkModal();
}

// Add Link
async function addLink(linkData) {
    try {
        const response = await fetch('/api/links', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(linkData)
        });
        
        if (response.ok) {
            loadLinks();
            showToast('Link added successfully!', 'success');
        } else {
            const error = await response.json();
            showToast(error.error || 'Error adding link', 'error');
        }
    } catch (error) {
        console.error('Error adding link:', error);
        showToast('Error adding link', 'error');
    }
}

// Delete Link
function confirmDeleteLink(index) {
    deletingIndex = index;
    document.getElementById('confirmMessage').textContent = `Are you sure you want to delete "${escapeHtml(links[index].title)}"?`;
    document.getElementById('confirmModal').classList.add('show');
}

async function confirmDelete() {
    if (deletingIndex !== null) {
        await deleteLink(deletingIndex);
        cancelDelete();
    }
}

function cancelDelete() {
    deletingIndex = null;
    document.getElementById('confirmModal').classList.remove('show');
}

async function deleteLink(index) {
    try {
        const response = await fetch(`/api/links/${index}`, {
            method: 'DELETE'
        });
        
        if (response.ok) {
            loadLinks();
            showToast('Link deleted successfully!', 'success');
        } else {
            showToast('Error deleting link', 'error');
        }
    } catch (error) {
        console.error('Error deleting link:', error);
        showToast('Error deleting link', 'error');
    }
}

// Save Links Order
async function saveLinksOrder() {
    try {
        const response = await fetch('/api/links/reorder', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ links })
        });
        
        if (!response.ok) {
            showToast('Error saving order', 'error');
        }
    } catch (error) {
        console.error('Error saving order:', error);
        showToast('Error saving order', 'error');
    }
}

// Settings Modal
function openSettingsModal() {
    document.getElementById('settingsModal').classList.add('show');
}

function closeSettingsModal() {
    document.getElementById('settingsModal').classList.remove('show');
}

// Export Configuration
async function exportConfig() {
    try {
        const response = await fetch('/api/config/export');
        
        if (response.ok) {
            const blob = await response.blob();
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `webportal_config_${new Date().toISOString().split('T')[0]}.yaml`;
            document.body.appendChild(a);
            a.click();
            window.URL.revokeObjectURL(url);
            document.body.removeChild(a);
            showToast('Configuration exported successfully!', 'success');
        }
    } catch (error) {
        console.error('Error exporting config:', error);
        showToast('Error exporting configuration', 'error');
    }
}

// Import Configuration
function triggerImport() {
    document.getElementById('importFile').click();
}

async function importConfig(event) {
    const file = event.target.files[0];
    if (!file) return;
    
    const formData = new FormData();
    formData.append('file', file);
    
    try {
        const response = await fetch('/api/config/import', {
            method: 'POST',
            body: formData
        });
        
        if (response.ok) {
            const result = await response.json();
            loadLinks();
            closeSettingsModal();
            showToast(`Configuration imported successfully! ${result.links_count} links loaded.`, 'success');
        } else {
            const error = await response.json();
            showToast(error.error || 'Error importing configuration', 'error');
        }
    } catch (error) {
        console.error('Error importing config:', error);
        showToast('Error importing configuration', 'error');
    }
    
    // Reset file input
    event.target.value = '';
}

// Utility Functions
function setColor(color) {
    document.getElementById('linkColor').value = color;
}

function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

function escapeHtmlAttr(text) {
    return text.replace(/&/g, '&amp;')
               .replace(/</g, '&lt;')
               .replace(/>/g, '&gt;')
               .replace(/"/g, '&quot;')
               .replace(/'/g, '&#039;');
}

// Toast Notification
function showToast(message, type = 'info') {
    const toast = document.getElementById('toast');
    toast.textContent = message;
    toast.className = `toast show ${type}`;
    
    setTimeout(() => {
        toast.classList.remove('show');
    }, 3000);
}
