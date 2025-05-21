import os
import re
import shutil
import threading
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor
from collections import defaultdict
import tkinter as tk
from tkinter import filedialog, messagebox, ttk
import ctypes
from datetime import datetime
import math

class XMLOrganizerApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Reroll XML Sorter")
        self.root.geometry("1000x700") 
        self.root.minsize(900, 650)
        
        # Set DPI awareness
        self.set_dpi_awareness()
        
        # Variables
        self.directory_path = tk.StringVar()
        self.status_var = tk.StringVar(value="Ready to organize XML files.")
        self.progress_var = tk.DoubleVar(value=0)
        self.file_groups = None
        self.reroll_summary = None
        self.regular_packs = None
        self.total_files = 0
        self.moved_files = 0
        
        # Configure custom fonts
        self.setup_fonts()
        
        # Create the UI
        self.create_widgets()
        
        # Configure style
        self.setup_styles()
        
        # Center the window
        self.center_window()
    
    def setup_fonts(self):
        """Setup custom fonts for the application"""
        self.header_font = ("Arial", 14, "bold")
        self.normal_font = ("Arial", 11)
        self.summary_font = ("Arial", 12)
        self.button_font = ("Arial", 11)
    
    def setup_styles(self):
        """Configure ttk styles with custom fonts"""
        self.style = ttk.Style()
        self.style.configure("TButton", font=self.button_font)
        self.style.configure("TLabel", font=self.normal_font)
        self.style.configure("Header.TLabel", font=self.header_font)
        self.style.configure("Summary.TLabel", font=self.summary_font)
    
    def set_dpi_awareness(self):
        """Set DPI awareness"""
        try:
            awareness = ctypes.c_int()
            errorCode = ctypes.windll.shcore.GetProcessDpiAwareness(0, ctypes.byref(awareness))
            if errorCode == 0:  # Success
                if awareness.value != 2:  # Ensure DPI aware
                    ctypes.windll.shcore.SetProcessDpiAwareness(2)  # PROCESS_PER_MONITOR_DPI_AWARE
        except Exception:
            try:
                # Check for older Windows versions
                ctypes.windll.user32.SetProcessDPIAware()
            except Exception:
                pass
    
    def center_window(self):
        """Center the window on the screen"""
        self.root.update_idletasks()
        width = self.root.winfo_width()
        height = self.root.winfo_height()
        x = (self.root.winfo_screenwidth() // 2) - (width // 2)
        y = (self.root.winfo_screenheight() // 2) - (height // 2)
        self.root.geometry(f"{width}x{height}+{x}+{y}")
    
    def create_widgets(self):
        """Create all UI widgets"""
        # Main frame
        main_frame = ttk.Frame(self.root, padding=10)
        main_frame.pack(fill=tk.BOTH, expand=True)
        
        # Directory selection
        dir_frame = ttk.Frame(main_frame)
        dir_frame.pack(fill=tk.X, pady=10)
        
        ttk.Label(dir_frame, text="XML Files Directory:", style="Header.TLabel").pack(side=tk.LEFT, padx=5)
        ttk.Entry(dir_frame, textvariable=self.directory_path, width=50, font=self.normal_font).pack(side=tk.LEFT, padx=5, fill=tk.X, expand=True)
        ttk.Button(dir_frame, text="Browse...", command=self.browse_directory).pack(side=tk.LEFT, padx=5)
        
        # Status bar at bottom
        status_frame = ttk.Frame(self.root)
        status_frame.pack(side=tk.BOTTOM, fill=tk.X)
        ttk.Label(status_frame, textvariable=self.status_var, relief=tk.SUNKEN, anchor=tk.W, font=self.normal_font).pack(fill=tk.X, expand=True, padx=5, pady=3)
        
        # Progress bar
        self.progress_bar = ttk.Progressbar(main_frame, variable=self.progress_var, maximum=100)
        self.progress_bar.pack(fill=tk.X, pady=10)
        
        # Notebook for different views
        self.notebook = ttk.Notebook(main_frame)
        self.notebook.pack(fill=tk.BOTH, expand=True, pady=10)
        
        # Summary tab - using a Frame with Labels instead of a Text widget
        self.summary_frame = ttk.Frame(self.notebook, padding=10)
        self.notebook.add(self.summary_frame, text="Summary")
        
        # Create a canvas with scrollbar for the summary content
        self.summary_canvas_frame = ttk.Frame(self.summary_frame)
        self.summary_canvas_frame.pack(fill=tk.BOTH, expand=True)
        
        self.summary_canvas = tk.Canvas(self.summary_canvas_frame, highlightthickness=0)
        self.summary_vsb = ttk.Scrollbar(self.summary_canvas_frame, orient="vertical", command=self.summary_canvas.yview)
        self.summary_canvas.configure(yscrollcommand=self.summary_vsb.set)
        
        self.summary_vsb.pack(side=tk.RIGHT, fill=tk.Y)
        self.summary_canvas.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        
        self.summary_content = ttk.Frame(self.summary_canvas)
        self.summary_canvas_window = self.summary_canvas.create_window((0, 0), window=self.summary_content, anchor="nw")
        
        # Setup for dynamic content
        self.summary_title = ttk.Label(self.summary_content, text="", style="Header.TLabel")
        self.summary_title.pack(anchor=tk.W, pady=(0, 10))
        
        self.summary_container = ttk.Frame(self.summary_content)
        self.summary_container.pack(fill=tk.BOTH, expand=True)
        
        # Configure canvas resize behavior
        self.summary_content.bind("<Configure>", self.on_frame_configure)
        self.summary_canvas.bind("<Configure>", self.resize_canvas_window)
        
        # Mouse wheel scroll binding for the canvas
        self.summary_canvas.bind_all("<MouseWheel>", self.on_mousewheel)
        
        # Details tab
        self.details_frame = ttk.Frame(self.notebook)
        self.notebook.add(self.details_frame, text="File Details")
        
        # Create treeview for file details
        self.tree = ttk.Treeview(self.details_frame, columns=("Filename", "Source", "Destination"), show="headings")
        tree_scroll = ttk.Scrollbar(self.details_frame, orient="vertical", command=self.tree.yview)
        self.tree.configure(yscrollcommand=tree_scroll.set)
        
        # Setup columns
        self.tree.heading("Filename", text="Filename")
        self.tree.heading("Source", text="Source")
        self.tree.heading("Destination", text="Destination")
        self.tree.column("Filename", width=250)
        self.tree.column("Source", width=150)
        self.tree.column("Destination", width=350)
        
        self.tree.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        tree_scroll.pack(side=tk.RIGHT, fill=tk.Y)
        
        # Log tab
        self.log_frame = ttk.Frame(self.notebook)
        self.notebook.add(self.log_frame, text="Operation Log")
        
        # Initialize log text widget
        self.log_text = tk.Text(self.log_frame, wrap=tk.WORD, height=20, width=80, font=self.normal_font)
        log_scrollbar = ttk.Scrollbar(self.log_frame, command=self.log_text.yview)
        self.log_text.configure(yscrollcommand=log_scrollbar.set)
        self.log_text.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=5, pady=5)
        log_scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        
        # Action buttons
        button_frame = ttk.Frame(main_frame)
        button_frame.pack(fill=tk.X, pady=10)
        
        # Exit button moved to left side
        ttk.Button(button_frame, text="Exit", command=self.root.destroy).pack(side=tk.LEFT, padx=5)
        
        # Move Files button on right side
        self.move_button = ttk.Button(button_frame, text="Move Files", command=self.show_confirmation_dialog, state=tk.DISABLED)
        self.move_button.pack(side=tk.RIGHT, padx=5)
    
    def on_frame_configure(self, event):
        """Reset the scroll region to encompass the inner frame"""
        self.summary_canvas.configure(scrollregion=self.summary_canvas.bbox("all"))
    
    def on_mousewheel(self, event):
        """Handle mouse wheel scrolling"""
        self.summary_canvas.yview_scroll(int(-1*(event.delta/120)), "units")
    
    def resize_canvas_window(self, event):
        """Resize the canvas window when the canvas is resized"""
        self.summary_canvas.itemconfig(self.summary_canvas_window, width=event.width)
    
    def browse_directory(self):
        """Open file dialog to select directory"""
        directory = filedialog.askdirectory(
            title="Select Directory containing XML files",
            initialdir=os.path.expanduser("~\\Desktop")
        )
        if directory:
            self.directory_path.set(directory)
            self.analyze_directory()
    
    def analyze_directory(self):
        """Analyze the selected directory for XML files"""
        directory = self.directory_path.get()
        if not directory:
            messagebox.showwarning("Warning", "Please select a directory first.")
            return
            
        if not os.path.exists(directory):
            messagebox.showerror("Error", f"Directory {directory} does not exist!")
            return
            
        # Clear previous data
        self.clear_ui()
        
        # Show analysis is in progress
        self.status_var.set("Analyzing directory...")
        self.root.update_idletasks()
        
        # Run analysis in a separate thread
        threading.Thread(target=self._analyze_directory_task, args=(directory,), daemon=True).start()
    
    def _analyze_directory_task(self, directory_path):
        """Background task for directory analysis"""
        try:
            dir_path = Path(directory_path)
            
            # Regex pattern for XML files
            pattern = r'(\d+)P(_\d+)+(\([A-Za-z]+\))*(.*\.xml)'
            timestamp_pattern = r'^.*(\d{14}_\d).*$'
            
            # Find all XML files recursively
            xml_files = []
            for file_path in dir_path.rglob('*.xml'):
                # Check if file is in "Sorted Accounts" folder
                parts = file_path.parts
                if "Sorted Accounts" in parts:
                    sa_index = parts.index("Sorted Accounts")
                    if parts[sa_index] == "Sorted Accounts" and sa_index == len(parts) - 2:
                        continue
                xml_files.append(file_path)
            
            self.total_files = len(xml_files)
            
            if not xml_files:
                self.root.after(0, lambda: self.status_var.set("No XML files found!"))
                return
            
            # Group files by their destination folders
            self.file_groups = defaultdict(list)
            self.reroll_summary = defaultdict(int)
            sorted_dir = dir_path / "Sorted Accounts"
            
            for file_path in xml_files:
                match = re.search(pattern, file_path.name)
                if match:
                    pack_number = int(match.group(1))
                    
                    # Extract timestamp if available
                    timestamp_match = re.search(timestamp_pattern, file_path.name)
                    timestamp = timestamp_match.group(1) if timestamp_match else None
                    
                    if pack_number >= 40:
                        # Determine range bucket
                        range_start = (pack_number // 10) * 10
                        range_end = range_start + 10
                        range_name = f"{range_start}-{range_end}"
                        
                        # Update reroll summary count
                        self.reroll_summary[range_name] += 1
                        
                        # Set destination folder
                        dest_folder = sorted_dir / "Reroll Ready" / range_name
                    else:
                        dest_name = f"{pack_number} Packs"
                        dest_folder = sorted_dir / dest_name
                    
                    self.file_groups[dest_folder].append(file_path)
            
            # Group regular packs
            self.regular_packs = {}
            for dest_folder, files in self.file_groups.items():
                if "Reroll Ready" not in dest_folder.parts:
                    match = re.match(r'(\d+) Packs', dest_folder.name)
                    if match:
                        pack_num = int(match.group(1))
                        self.regular_packs[pack_num] = len(files)
            
            # Update UI with results
            self.root.after(0, self.update_analysis_results)
            
        except Exception as e:
            self.root.after(0, lambda: messagebox.showerror("Error", f"Error analyzing directory: {str(e)}"))
            self.root.after(0, lambda: self.status_var.set("Analysis failed."))
    
    def update_analysis_results(self):
        """Update UI with analysis results"""
        # Clear previous summary content
        for widget in self.summary_container.winfo_children():
            widget.destroy()
        
        # Update summary title
        self.summary_title.config(text=f"Total XML files found: {self.total_files}")
        
        # Add organization info
        ttk.Label(self.summary_container, 
                 text="Files will be organized as follows:", 
                 font=self.header_font).pack(anchor=tk.W, pady=(5, 10))
        
        # Create grid layout for better organization
        if self.regular_packs or self.reroll_summary:
            pack_frame = ttk.Frame(self.summary_container)
            pack_frame.pack(fill=tk.BOTH, expand=True)
            
            # Regular packs section with grid layout for multiple columns
            if self.regular_packs:
                reg_frame = ttk.LabelFrame(pack_frame, text="Regular Pack Folders", padding=10)
                reg_frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=(0, 10))
                
                # Determine optimal column count
                num_packs = len(self.regular_packs)
                if num_packs <= 13:  # Original single column layout
                    columns = 1
                elif num_packs <= 26:  # Two columns for 14-26 packs
                    columns = 2
                else:  # Three columns for 27-39 packs
                    columns = 3
                
                rows = math.ceil(num_packs / columns)
                
                # Create a grid of frames for better layout
                grid_frames = []
                for col in range(columns):
                    col_frame = ttk.Frame(reg_frame)
                    col_frame.grid(row=0, column=col, sticky="nw", padx=5)
                    grid_frames.append(col_frame)
                
                # Sort packs and distribute them across columns
                sorted_packs = sorted(self.regular_packs.keys())
                for i, pack_num in enumerate(sorted_packs):
                    col_idx = i // rows
                    frame = grid_frames[min(col_idx, len(grid_frames)-1)]
                    ttk.Label(
                        frame, 
                        text=f"{pack_num} Packs: {self.regular_packs[pack_num]} files",
                        font=self.summary_font
                    ).pack(anchor=tk.W, pady=2)
            
            # Reroll Ready packs section (right side)
            if self.reroll_summary:
                reroll_frame = ttk.LabelFrame(pack_frame, text="Reroll Ready", padding=10)
                reroll_frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
                
                total_reroll = sum(self.reroll_summary.values())
                ttk.Label(
                    reroll_frame, 
                    text=f"Total: {total_reroll} files",
                    font=self.summary_font
                ).pack(anchor=tk.W, pady=(0, 5))
                
                for range_name, count in sorted(self.reroll_summary.items(), key=lambda item: int(item[0].split('-')[0])):
                    ttk.Label(
                        reroll_frame, 
                        text=f"{range_name} Packs: {count} files",
                        font=self.summary_font
                    ).pack(anchor=tk.W, pady=2)
        
        # Populate file details tree
        self.populate_file_details()
        
        # Enable move button if files were found
        if self.total_files > 0:
            self.move_button.config(state=tk.NORMAL)
        
        self.status_var.set(f"Analysis complete. Found {self.total_files} XML files.")
    
    def populate_file_details(self):
        """Populate the file details treeview"""
        # Clear existing items
        for item in self.tree.get_children():
            self.tree.delete(item)
        
        # Add new items
        for dest_folder, files in self.file_groups.items():
            for file_path in files:
                rel_source = file_path.relative_to(Path(self.directory_path.get())) if file_path.is_relative_to(Path(self.directory_path.get())) else file_path
                self.tree.insert("", tk.END, values=(file_path.name, str(rel_source.parent), str(dest_folder)))
    
    def show_confirmation_dialog(self):
        """Show confirmation dialog before moving files"""
        result = messagebox.askyesno(
            "Confirm Operation",
            f"Do you want to move {self.total_files} files as shown in the summary?\n\n"
            "This will create the necessary folders and move all files to their destinations.",
            icon=messagebox.WARNING
        )
        
        if result:
            self.move_files()
    
    def move_files(self):
        """Move files according to the analysis"""
        # Disable UI elements during operation
        self.move_button.config(state=tk.DISABLED)
        self.status_var.set("Moving files...")
        self.progress_var.set(0)
        
        # Clear log
        self.log_text.config(state=tk.NORMAL)
        self.log_text.delete(1.0, tk.END)
        self.log_text.insert(tk.END, f"Operation started at {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
        self.log_text.config(state=tk.DISABLED)
        
        # Switch to log tab
        self.notebook.select(self.log_frame)
        
        # Start the operation in a separate thread
        threading.Thread(target=self._move_files_task, daemon=True).start()
    
    def _move_files_task(self):
        """Background task for moving files"""
        try:
            # Create all destination folders
            for dest_folder in self.file_groups.keys():
                dest_folder.mkdir(parents=True, exist_ok=True)
            
            # Prepare move tasks
            move_tasks = [(file_path, dest_folder)
                        for dest_folder, files in self.file_groups.items()
                        for file_path in files]
            
            # Reset counters
            self.moved_files = 0
            success_count = 0
            
            # Move files
            max_workers = os.cpu_count() or 4
            with ThreadPoolExecutor(max_workers=max_workers) as executor:
                futures = []
                for task in move_tasks:
                    futures.append(executor.submit(self.move_file, *task))
                
                # Process results as they complete
                for future in futures:
                    success, message = future.result()
                    if success:
                        success_count += 1
                    
                    # Update log
                    self.root.after(0, lambda msg=message: self.update_log(msg))
                    
                    # Update progress
                    self.moved_files += 1
                    progress = (self.moved_files / self.total_files) * 100
                    self.root.after(0, lambda p=progress: self.progress_var.set(p))
            
            # Final update
            final_message = f"\nOperation complete! Successfully moved {success_count} of {len(move_tasks)} files."
            self.root.after(0, lambda: self.update_log(final_message))
            self.root.after(0, lambda: self.status_var.set(f"Operation complete. Moved {success_count}/{len(move_tasks)} files."))
            self.root.after(0, lambda: self.progress_var.set(100))
            
            # Show completion message
            self.root.after(0, lambda: messagebox.showinfo("Operation Complete", 
                f"Successfully moved {success_count} of {len(move_tasks)} files.\n\n"
                "See the Operation Log tab for details."
            ))
            
        except Exception as e:
            self.root.after(0, lambda: messagebox.showerror("Error", f"Error during file move operation: {str(e)}"))
            self.root.after(0, lambda: self.status_var.set("Operation failed."))
    
    def move_file(self, file_path, dest_folder):
        """Move a single file and return result"""
        try:
            base_dest_file = dest_folder / file_path.name
            dest_file = base_dest_file
            counter = 1
            
            # Handle file name conflicts
            while dest_file.exists():
                name_parts = file_path.stem.split('.')
                new_name = f"{name_parts[0]}({counter}){file_path.suffix}"
                dest_file = dest_folder / new_name
                counter += 1
            
            if not file_path.exists():
                return False, f"Source file {file_path.name} no longer exists"
            
            shutil.move(str(file_path), str(dest_file))
            
            if dest_file != base_dest_file:
                return True, f"Moved {file_path.name} to {dest_folder} as {dest_file.name}"
            return True, f"Moved {file_path.name} to {dest_folder}"
            
        except Exception as e:
            return False, f"Error moving {file_path.name}: {e}"
    
    def update_log(self, message):
        """Update the log text widget"""
        self.log_text.config(state=tk.NORMAL)
        self.log_text.insert(tk.END, message + "\n")
        self.log_text.see(tk.END)
        self.log_text.config(state=tk.DISABLED)
    
    def clear_ui(self):
        """Clear UI elements for new analysis"""
        # Clear summary content
        self.summary_title.config(text="")
        for widget in self.summary_container.winfo_children():
            widget.destroy()
        
        # Clear tree view
        for item in self.tree.get_children():
            self.tree.delete(item)
            
        # Clear log
        self.log_text.config(state=tk.NORMAL)
        self.log_text.delete(1.0, tk.END)
        self.log_text.config(state=tk.DISABLED)
        
        self.progress_var.set(0)
        self.move_button.config(state=tk.DISABLED)

def main():
    root = tk.Tk()
    app = XMLOrganizerApp(root)
    root.mainloop()

if __name__ == "__main__":
    main()
