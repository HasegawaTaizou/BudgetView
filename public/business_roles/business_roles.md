### **Regras de Negócio (RNs)**  

#### **1. Regras para `TBL_TRANSACTION` (Transações)**  
- **RN01** - Cada transação deve ter um `id_transaction` único e auto incrementado.  
- **RN02** - O campo `name` deve ser preenchido obrigatoriamente e ter no máximo 100 caracteres.  
- **RN03** - O valor da transação (`value`) deve ser maior que zero e pode conter até duas casas decimais.  
- **RN04** - O campo `date` deve armazenar a data da transação e não pode ser futura.  
- **RN05** - Toda transação deve estar associada a uma categoria válida (`id_category`).  
- **RN06** - Uma transação só pode pertencer a uma única categoria.  
- **RN07** - Deve ser possível listar todas as transações filtrando por data, categoria e tipo.  

#### **2. Regras para `TBL_CATEGORY` (Categorias)**  
- **RN08** - Cada categoria deve ter um `id_category` único e auto incrementado.  
- **RN9** - O nome da categoria deve ser único e conter no máximo 45 caracteres.  
- **RN10** - Uma categoria pode estar associada a várias transações.  
- **RN11** - Cada categoria deve estar vinculada a um tipo (`id_type`), garantindo que todas as transações dessa categoria sigam essa classificação.  
- **RN12** - Uma categoria deve ter um ícone associado (`id_icon`).  

#### **3. Regras para `TBL_TYPE` (Tipos de Categoria)**  
- **RN13** - Cada tipo deve ter um `type_id` único e auto incrementado.  
- **RN14** - O campo `type` deve ser um ENUM contendo valores predefinidos, como `("SPEND", "EARN")`.  
- **RN15** - Cada categoria deve estar vinculada a um tipo (`id_type`).  
- **RN16** - Não é permitido cadastrar categorias sem um tipo definido.  
- **RN17** - Não é permitido excluir um tipo (`id_type`) se houver categorias associadas a ele.  
- **RN18** - Deve ser possível listar todas as transações filtrando pelo tipo.  

#### **4. Regras para `TBL_ICON` (Ícones)**  
- **RN19** - Cada ícone deve ter um `id_icon` único e auto incrementado.  
- **RN20** - O campo `icon` deve armazenar a imagem em formato BLOB.  
- **RN21** - Um ícone pode ser associado a uma ou mais categorias.  

#### **5. Regras Gerais**  
- **RN22** - Todas as chaves estrangeiras devem garantir integridade referencial, impedindo a criação de registros órfãos.  
- **RN23** - Deve ser possível gerar relatórios de transações agrupadas por categoria, tipo e período.  