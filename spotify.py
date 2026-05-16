import os
import requests
import base64

# 1. Map out your 10 static favorite tracks with their Spotify CDN image links
TRACKS = {
    "1": {"title": "Ode to the Mets", "artist": "The Strokes", "img_url": "https://i.scdn.co/image/ab67616d0000b273aeaa1d05492af796a0907406"},
    "2": {"title": "Don't Look Back in Anger", "artist": "Oasis", "img_url": "https://i.scdn.co/image/ab67616d0000b273d4dfbf70327f12e0941da78f"},
    "3": {"title": "Concorde", "artist": "Black Country, New Road", "img_url": "https://i.scdn.co/image/ab67616d0000b273574c3e660b4578b7b2520847"},
    "4": {"title": "Creep (Live)", "artist": "Stone Temple Pilots", "img_url": "https://i.scdn.co/image/ab67616d0000b273a0e10b2df7e812d4d9af9054"},
    "5": {"title": "Let Down", "artist": "Radiohead", "img_url": "https://i.scdn.co/image/ab67616d0000b273950ef316ecac632f06b9b3e1"},
    "6": {"title": "Perfect", "artist": "The Smashing Pumpkins", "img_url": "https://i.scdn.co/image/ab67616d0000b273ca803ef5b96791986420e6f7"},
    "7": {"title": "Girl of the Year", "artist": "Beach House", "img_url": "https://i.scdn.co/image/ab67616d0000b273b0629705b4520f92275f0a0d"},
    "8": {"title": "They'll Only Miss You...", "artist": "Carissa's Wierd", "img_url": "https://i.scdn.co/image/ab67616d0000b273ef56e792c3004bb9d290744d"},
    "9": {"title": "23", "artist": "Jimmy Eat World", "img_url": "https://i.scdn.co/image/ab67616d0000b2736b41cb91fa164369a039fc7f"},
    "10": {"title": "Rotten Apple", "artist": "Alice in Chains", "img_url": "https://i.scdn.co/image/ab67616d0000b273764b8cf6bb3db942fe29bcfe"}
}

# 2. The custom SVG layout matching the dashboard aesthetic you liked
SVG_TEMPLATE = """<svg xmlns="http://www.w3.org/2000/svg" width="300" height="85" viewBox="0 0 300 85" fill="none">
    <style>
        .bg {{ fill: #121212; rx: 6px; }}
        .title {{ font: bold 13px 'Segoe UI', Ubuntu, sans-serif; fill: #FFFFFF; }}
        .artist {{ font: 11px 'Segoe UI', Ubuntu, sans-serif; fill: #B3B3B3; }}
        .fav-tag {{ font: bold 9px 'Segoe UI', Ubuntu, sans-serif; fill: #1DB954; letter-spacing: 1px; }}
        .bar {{ fill: #1DB954; transform-origin: bottom; }}
    </style>
    
    <rect class="bg" width="300" height="85" />
    
    <clipPath id="inner-radius">
        <rect x="10" y="10" width="65" height="65" rx="4" />
    </clipPath>
    <image x="10" y="10" width="65" height="65" clip-path="url(#inner-radius)" href="data:image/png;base64,{b64_image}" />
    
    <text x="88" y="25" class="fav-tag">FAVORITE TRACK</text>
    <text x="88" y="44" class="title">{title}</text>
    <text x="88" y="62" class="artist">{artist}</text>
    
    <g transform="translate(255, 45)">
        <rect class="bar" x="0" y="0" width="3" height="18" rx="1" transform="scale(1, 0.7)" />
        <rect class="bar" x="5" y="0" width="3" height="18" rx="1" transform="scale(1, 0.9)" />
        <rect class="bar" x="10" y="0" width="3" height="18" rx="1" transform="scale(1, 0.4)" />
        <rect class="bar" x="15" y="0" width="3" height="18" rx="1" transform="scale(1, 0.8)" />
    </g>
</svg>"""

def get_base64_image(url):
    """Downloads the Spotify artwork and converts it to base64 string format"""
    try:
        response = requests.get(url, timeout=10)
        if response.status_code == 200:
            return base64.b64encode(response.content).decode('utf-8')
    except Exception as e:
        print(f"Error fetching image: {e}")
    return ""

def main():
    os.makedirs("spotify-assets", exist_ok=True)
    print("🎨 Generating your 10 custom static music cards...")
    
    for track_id, info in TRACKS.items():
        print(f"📦 Processing: {info['title']} by {info['artist']}")
        
        b64_data = get_base64_image(info['img_url'])
        
        final_svg = SVG_TEMPLATE.format(
            title=info['title'],
            artist=info['artist'],
            b64_image=b64_data
        )
        
        file_path = f"spotify-assets/track_{track_id}.svg"
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(final_svg)
            
    print("✨ Execution complete! All 10 SVG cards are saved inside /spotify-assets")

if __name__ == "__main__":
    main()
