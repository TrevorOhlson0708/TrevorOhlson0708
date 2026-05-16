import os
import base64

TRACKS = {
    "1": {"title": "Ode to the Mets", "artist": "The Strokes", "filename": "1.jpg"},
    "2": {"title": "Don't Look Back in Anger", "artist": "Oasis", "filename": "2.jpg"},
    "3": {"title": "Concorde", "artist": "Black Country, New Road", "filename": "3.jpg"},
    "4": {"title": "Creep (Live)", "artist": "Stone Temple Pilots", "filename": "4.jpg"},
    "5": {"title": "Let Down", "artist": "Radiohead", "filename": "5.jpg"},
    "6": {"title": "Perfect", "artist": "The Smashing Pumpkins", "filename": "6.jpeg"},
    "7": {"title": "Girl of the Year", "artist": "Beach House", "filename": "7.jpg"},
    "8": {"title": "They'll Only Miss You...", "artist": "Carissa's Wierd", "filename": "8.jpg"},
    "9": {"title": "23", "artist": "Jimmy Eat World", "filename": "9.jpg"},
    "10": {"title": "Rotten Apple", "artist": "Alice in Chains", "filename": "10.jpg"}
}

SVG_TEMPLATE = """<svg xmlns="http://www.w3.org/2000/svg" width="300" height="85" viewBox="0 0 300 85" fill="none">
    <style>
        .bg {{ fill: #121212; rx: 6px; }}
        .title {{ font: bold 12px 'Segoe UI', Ubuntu, sans-serif; fill: #FFFFFF; }}
        .artist {{ font: 10px 'Segoe UI', Ubuntu, sans-serif; fill: #B3B3B3; }}
        .fav-tag {{ font: bold 8px 'Segoe UI', Ubuntu, sans-serif; fill: #1DB954; letter-spacing: 1px; }}
        .bar {{ fill: #1DB954; transform-origin: bottom; }}
    </style>
    <rect class="bg" width="300" height="85" />
    <clipPath id="inner-radius">
        <rect x="10" y="10" width="65" height="65" rx="4" />
    </clipPath>
    <image x="10" y="10" width="65" height="65" clip-path="url(#inner-radius)" href="data:image/jpeg;base64,{b64_image}" />
    <text x="85" y="23" class="fav-tag">FAVORITE TRACK</text>
    <text x="85" y="42" class="title">{title}</text>
    <text x="85" y="60" class="artist">{artist}</text>
    <g transform="translate(255, 45)">
        <rect class="bar" x="0" y="0" width="3" height="18" rx="1" transform="scale(1, 0.7)" />
        <rect class="bar" x="5" y="0" width="3" height="18" rx="1" transform="scale(1, 0.9)" />
        <rect class="bar" x="10" y="0" width="3" height="18" rx="1" transform="scale(1, 0.4)" />
        <rect class="bar" x="15" y="0" width="3" height="18" rx="1" transform="scale(1, 0.8)" />
    </g>
</svg>"""

def main():
    print("🎨 Initializing Local Base64 Music Asset Compilation...")
    
    # Paths based on execution directory
    base_dir = os.path.dirname(os.path.abspath(__file__))
    covers_dir = os.path.join(base_dir, "covers")
    
    for track_id, info in TRACKS.items():
        file_path = os.path.join(covers_dir, info['filename'])
        
        if not os.path.exists(file_path):
            print(f"❌ Missing target file: {file_path}. Skipping {info['title']}.")
            continue
            
        try:
            # Open image binary data straight from your hard drive
            with open(file_path, "rb") as image_file:
                b64_data = base64.b64encode(image_file.read()).decode('utf-8')
                
            print(f"✅ Locally compiled image string for: {info['title']}")
            
            final_svg = SVG_TEMPLATE.format(
                title=info['title'],
                artist=info['artist'],
                b64_image=b64_data
            )
            
            output_path = os.path.join(base_dir, f"track_{track_id}.svg")
            with open(output_path, "w", encoding="utf-8") as f:
                f.write(final_svg)
                
        except Exception as e:
            print(f"🚨 Read Error on track {track_id}: {e}")
            
    print("✨ Process complete! All SVGs generated with zero external network overhead.")

if __name__ == "__main__":
    main()
