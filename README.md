# LeilaSalon

## 🛠️ Tecnologias Utilizadas

### SwiftUI
- **Motivo da escolha**: Interface declarativa moderna da Apple, otimizada para produtividade e fácil manutenção.

### SwiftData
- **Motivo da escolha**: Framework oficial da Apple para persistência de dados, integrado nativamente com SwiftUI, além de ser simples e eficiente.

### Supabase
- **Motivo da escolha**: Backend como serviço (BaaS) open-source, alternativa ao Firebase, permite autenticação e banco de dados em tempo real.

### MVVM + Clean Architecture
- **Motivo da escolha**:
  - **MVVM**: Separa lógica de negócios da interface visual, facilitando testes e manutenção.
  - **Clean Architecture**: Diminui acoplamento e aumenta testabilidade através da divisão em camadas: Presentation, Domain e Data.

### Coordinator Pattern
- **Motivo da escolha**: Desacopla a navegação da view.

### WidgetKit
- **Motivo da escolha**: API Apple que permite ao usuário acessar informações importantes diretamente da tela inicial.

---

## 🧱 Arquitetura do Projeto

```
LeilaSalon/
├── Src/
│   ├── Core/
│   │   ├── Utilities/
│   │   ├── Extensions/
│   │   └── Protocols/
│   ├── Modules/
│   │   ├── Authentication/
│   │   │   ├── UI/
│   │   │   │   └── View/
│   │   │   │   └── ViewModels/
│   │   │   ├── Domain/
│   │   │   └── Data/
│   │   │       └── Repositories/
│   │   ├── Home/
│   │   │   ├── UI/
│   │   │   │   └── View/
│   │   │   │   └── ViewModels/
│   │   │   ├── Domain/
│   │   │   └── Data/
│   │   │       └── Repositories/
│   │   └── Schedule/
│   │       ├── UI/
│   │       │   └── View/
│   │       │   └── ViewModels/
│   │       ├── Domain/
│   │       └── Data/
│   │           └── Repositories/
│   ├── Shared/
│   │   ├── Components/
│   │   └── Resources/
│   └── AppCoordinator.swift
├── Widgets/
│   └── LeilaSalonWidget.swift
└── Tests/
```

---

## ▶️ Como Executar

1. Clone o repositório:
```bash
git clone https://github.com/izadoramatias/cabeleileila-mobile-app.git
```

2. Abra o projeto no Xcode:
```bash
cd cabeleileila-mobile-app
open leilaSalon.xcodeproj
```

3. Compile e execute no simulador ou dispositivo iOS.

---

## 🧪 Testes

O projeto inclui testes unitários. Para executá-los:

1. Pressione `Cmd+U`.

---

## 📌 Observações

1. Login admin
   - email: leila@salon.com
   - senha: leilaAdm@26
2. Para acessar como cliente cabeleileilo, crie seu proprio login clicando em `Cadastrar-se` na tela de login do app.


<img width="300" alt="Simulator Screenshot - Clone 3 of iPhone 17 Pro Max - 2026-06-19 at 00 55 39" src="https://github.com/user-attachments/assets/836c19c0-e17e-441e-8d51-835d02f231ba" />
<img width="300" alt="Simulator Screenshot - Clone 3 of iPhone 17 Pro Max - 2026-06-19 at 00 54 59" src="https://github.com/user-attachments/assets/4cfd4151-bcd5-49af-8dea-5ce37c0b50f7" />

