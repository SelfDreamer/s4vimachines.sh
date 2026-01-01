package main

import (
	"flag"
	"fmt"
	"io"
	"os"
	"strings"

	"github.com/charmbracelet/bubbles/textarea"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
	"github.com/muesli/termenv" 
)

var (
	colorCursor           = lipgloss.Color("#F633A3") 
	colorText             = lipgloss.Color("#E1E1E1")
	colorPlaceholder      = lipgloss.Color("#5C5C5C")
	colorHighlightBg      = lipgloss.Color("#2A2A2A")
	colorFooterText       = lipgloss.Color("#626262") 
	colorLineNumber       = lipgloss.Color("#3C3C3C") 
	colorActiveLineNumber = lipgloss.Color("#ee9561") 

	footerStyle = lipgloss.NewStyle().
			Foreground(colorFooterText).
			PaddingTop(1)
)

var (
	width       = flag.Int("width", 0, "Ancho inicial (0 para automático)")
	height      = flag.Int("height", 20, "Alto inicial (0 para automático)")
	placeholder = flag.String("placeholder", "Introduce tu nota...", "Texto de ayuda")
	value       = flag.String("value", "", "Texto inicial pre-cargado")
	highlight   = flag.Bool("highlight-line", true, "Resaltar visualmente la línea actual")
	showLineNum = flag.Bool("show-line-numbers", true, "Mostrar números de línea")
)

func main() {
	flag.Parse()

	lipgloss.SetColorProfile(termenv.TrueColor)

	textoInicial := *value
	if textoInicial == "" {
		stat, _ := os.Stdin.Stat()
		if (stat.Mode() & os.ModeCharDevice) == 0 {
			stdin, _ := io.ReadAll(os.Stdin)
			textoInicial = strings.TrimSuffix(string(stdin), "\n")
		}
	}

	ta := textarea.New()
	ta.Placeholder = *placeholder
	ta.SetValue(textoInicial)
	ta.Focus()
	ta.ShowLineNumbers = *showLineNum

	styleBase := lipgloss.NewStyle().Foreground(colorText)
	ta.FocusedStyle.Base = styleBase
	ta.BlurredStyle.Base = styleBase

	ta.Cursor.Style = lipgloss.NewStyle().
		Background(colorCursor).
		Foreground(lipgloss.Color("#FFFFFF"))

	stylePlaceholder := lipgloss.NewStyle().Foreground(colorPlaceholder)
	ta.FocusedStyle.Placeholder = stylePlaceholder
	ta.BlurredStyle.Placeholder = stylePlaceholder

	styleLineNum := lipgloss.NewStyle().Foreground(colorLineNumber).PaddingLeft(2)
	ta.FocusedStyle.LineNumber = styleLineNum
	ta.BlurredStyle.LineNumber = styleLineNum

	styleActiveLineNum := lipgloss.NewStyle().Foreground(colorActiveLineNumber).Bold(true).PaddingLeft(0)
	ta.FocusedStyle.CursorLineNumber = styleActiveLineNum
	
	var styleCursorLine lipgloss.Style
	if *highlight {
		styleCursorLine = lipgloss.NewStyle().Background(colorHighlightBg)
	} else {
		styleCursorLine = lipgloss.NewStyle()
	}
	ta.FocusedStyle.CursorLine = styleCursorLine
	ta.BlurredStyle.CursorLine = styleCursorLine

	if *width > 0 { ta.SetWidth(*width) }
	if *height > 0 { ta.SetHeight(*height) }

	p := tea.NewProgram(
		model{textarea: ta}, 
		tea.WithOutput(os.Stderr), 
	)

	m, err := p.Run()
	if err != nil {
		fmt.Printf("Error: %v", err)
		os.Exit(1)
	}

	finalModel := m.(model)
	if !finalModel.aborted {
		fmt.Println(finalModel.textarea.Value())
	}
}

type model struct {
	textarea textarea.Model
	aborted  bool
}

func (m model) Init() tea.Cmd {
	return textarea.Blink
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	var cmds []tea.Cmd
	var cmd tea.Cmd

	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		if *height == 0 { m.textarea.SetHeight(msg.Height - 2) }
		if *width == 0 { m.textarea.SetWidth(msg.Width) }

	case tea.KeyMsg:
		switch msg.Type {
		case tea.KeyCtrlC, tea.KeyEsc:
			m.aborted = true
			return m, tea.Quit
		case tea.KeyCtrlD:
			return m, tea.Quit
		case tea.KeyTab:
			m.textarea.InsertString("    ")
			return m, nil
		}
	}

	m.textarea, cmd = m.textarea.Update(msg)
	cmds = append(cmds, cmd)
	return m, tea.Batch(cmds...)
}

func (m model) View() string {
	helpText := "ctrl+c cancel • ctrl+d submit"
	return lipgloss.JoinVertical(
		lipgloss.Left,
		m.textarea.View(),
		footerStyle.Render(helpText),
	)
}
