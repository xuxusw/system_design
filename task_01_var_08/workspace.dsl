workspace "Projex" "Система управления проектами"

    !identifiers hierarchical

    model {
        # Roles
        admin = person "Admin" "Управляет системой" {
            tags "role"
        }        

        projectManager = person "Project Manager" "Управляет проектами" {
            tags "role"
        }

        productOwner = person "Product Owner" "Управляет требованиями" {
            tags "role"
        }

        teamLead = person "Team Lead" "Распределяет задачи" {
            tags "role"
        }
        
        developer = person "Developer" "Выполняет задачи" {
            tags "role"
        }
        
        tester = person "Tester" "Проверяет выполненные задачи" {
            tags "role"
        }
        
        stakeholder = person "Stakeholder" "Наблюдает за прогрессом проектов" {
            tags "role"
        }


        # External systems
        emailGateway = softwareSystem "Email Gateway" {
            tags "external"
        }

        authProvider = softwareSystem "Identity Provider" {
            tags "external"
        }

        github = softwareSystem "GitHub Integration" {
            tags "external"
        }

        ciCd = softwareSystem "CI/CD Pipeline" {
            tags "external"
        }

        # Main system
        pms = softwareSystem "Project Management System" {
            spa = container "Single Page Application" {
                technology "React 18, TypeScript, Vite, MUI 5, React Query, Socket.io-client"
                tags "frontend"
            }

            mobile = container "Mobile App" {
                technology "React Native, Expo, Redux Toolkit, SQLite"
                tags "mobile"
            }

            gateway = container "API Gateway" {
                technology "Spring Cloud Gateway, Java 17, JWT, Resilience4j"
                tags "backend"
            }

            # Сервис пользователей
            userService = container "User Service" "Управление пользователями, ролями, правами доступа, командами и оргструктурой" {
                technology "Spring Boot 3, Java 17, Spring Security, REST API, gRPC, Redis"
                tags "microservice"
                properties {
                    "api:createUser" "POST /users"
                    "api:findByLogin" "GET /users?login={login}"
                    "api:findByNameMask" "GET /users?nameMask={mask}"
                }
            }

            # Сервис проектов с поддержкой иерархии
            projectService = container "Project Service" "Управление проектами, портфелями, программами, шаблонами проектов, метаданными" {
                technology "Spring Boot 3, Java 17, REST API, gRPC, Elasticsearch"
                tags "microservice"
                properties {
                    "api:createProject" "POST /projects"
                    "api:findProjectByName" "GET /projects?name={name}"
                    "api:findAllProjects" "GET /projects"
                }
            }

            # Сервис задач с workflow
            taskService = container "Task Service" "Управление задачами, подзадачами, эпиками, багами, кастомными workflow, история изменений, time tracking" {
                technology "Spring Boot 3, Java 17, REST API, gRPC, Camunda"
                tags "microservice"
                properties {
                    "api:createTask" "POST /tasks"
                    "api:getTasksByProject" "GET /projects/{projectId}/tasks"
                    "api:getTaskByCode" "GET /tasks/{taskCode}"
                }
            }

            # Сервис активности
            activityService = container "Activity Service" "Комментарии к задачам, упоминания, лента активности, уведомления в реальном времени" {
                technology "Spring Boot 3, Java 17, WebSocket, Kafka, MongoDB"
                tags "microservice"
            }

            # Сервис аналитики и отчетов
            analyticsService = container "Analytics Service" "Сбор метрик, формирование отчетов, дашборды, экспорт в Excel/PDF" {
                technology "Spring Boot 3, Java 17, Apache Spark, JasperReports"
                tags "microservice"
            }

            # Сервис файлов и вложений
            fileService = container "File Service" "Загрузка/скачивание файлов, прикрепление к задачам, превью изображений" {
                technology "Spring Boot 3, Java 17, MinIO/S3 для хранения, ImageMagick для обработки"
                tags "microservice"
            }

            # Сервис интеграций
            integrationService = container "Integration Service" "Адаптеры для внешних систем (Github), вебхуки, синхронизация данных" {
                technology "Spring Boot 3, Java 17, Apache Camel, Kafka для событий"
                tags "microservice"
            }


            # Базы данных
            postgresUsers = container "PostgreSQL (Users)" "Хранение пользователей, ролей, прав доступа, команд" {
                technology "PostgreSQL 15"
                tags "database"
            }
            
            postgresProjects = container "PostgreSQL (Projects)" "Хранение проектов, портфелей, метаданных, настроек" {
                technology "PostgreSQL 15"
                tags "database"
            }
            
            postgresTasks = container "PostgreSQL (Tasks)" "Хранение задач, истории изменений, workflow, связей между задачами" {
                technology "PostgreSQL 15, JSONB"
                tags "database"
            }
            
            mongoActivity = container "MongoDB (Activity)" "Хранение логов активности, комментариев, уведомлений" {
                technology "MongoDB 6, TTL indexes"
                tags "database"
            }
            
            redisCache = container "Redis Cache" "Кэширование сессий, токенов, часто запрашиваемых данных" {
                technology "Redis 7, Redis Cluster"
                tags "cache"
            }
            
            kafka = container "Kafka Event Bus" "Асинхронное взаимодействие между микросервисами, событийная шина" {
                technology "Apache Kafka 3, KRaft mode, Schema Registry"
                tags "message-bus"
            }
            
            elastic = container "Elasticsearch" "Полнотекстовый поиск по задачам, проектам, комментариям" {
                technology "Elasticsearch 8, Kibana для визуализации"
                tags "search"
            }

            minio = container "MinIO Storage" "Хранилище для файлов и вложений" {
                technology "MinIO"
                tags "storage"
            }

            # ВНУТРЕННИЕ СВЯЗИ
            spa -> gateway "REST API + WebSocket для real-time обновлений" "HTTPS/WSS"
            mobile -> gateway "API + WebSocket для мобильных клиентов" "HTTPS/WSS"

            gateway -> userService "Управление пользователями" "gRPC"
            gateway -> projectService "Управление проектами" "gRPC"
            gateway -> taskService "Управление задачами" "gRPC"
            gateway -> activityService "Комментарии и активность" "gRPC"
            gateway -> analyticsService "Отчеты и аналитика" "gRPC"
            gateway -> fileService "Работа с файлами" "gRPC"
            gateway -> integrationService "Внешние интеграции" "gRPC"

            # Асинхронные события
            userService -> kafka "Публикация событий: UserCreated, UserUpdated, UserDeleted" "Kafka API"
            projectService -> kafka "Публикация событий: ProjectCreated, ProjectUpdated" "Kafka API"
            taskService -> kafka "Публикация событий: TaskCreated, TaskUpdated, TaskCommented" "Kafka API"
            activityService -> kafka "Публикация событий: NewComment, UserMentioned" "Kafka API"
            kafka -> activityService "Потребление событий для ленты активности" "Kafka API"
            kafka -> analyticsService "Потребление событий для сбора метрик" "Kafka API"
            kafka -> integrationService "Потребление событий для отправки во внешние системы" "Kafka API"

            # Запись в базы данных
            userService -> postgresUsers "CRUD операции с пользователями" "JDBC"
            userService -> redisCache "Кэширование сессий и профилей" "Redis"
            
            projectService -> postgresProjects "CRUD операции с проектами" "JDBC"
            projectService -> elastic "Индексация проектов для поиска" "REST"
            
            taskService -> postgresTasks "CRUD операции с задачами" "JDBC"
            taskService -> elastic "Индексация задач для поиска" "REST"
            
            activityService -> mongoActivity "Запись комментариев и логов" "MongoDB"
            
            fileService -> minio "Загрузка/скачивание файлов" "S3 API"
            
            integrationService -> elastic "Поиск для синхронизации" "REST"


            # ВНЕШНИЕ СВЯЗИ
            gateway -> authProvider "Аутентификация пользователей через SSO" "OIDC"
            activityService -> emailGateway "Отправка email при упоминаниях и назначениях" "SMTP"
            integrationService -> github "Webhook: синхронизация коммитов с задачами" "HTTPS"
            integrationService -> ciCd "Обновление статуса сборки в задачах" "HTTPS"


            # СВЯЗИ ПОЛЬЗОВАТЕЛЕЙ
            admin -> spa "Управление системой" "HTTPS"
            projectManager -> spa "Управление проектами" "HTTPS"
            productOwner -> spa "Управление бэклогом" "HTTPS"
            teamLead -> spa "Управление командой и задачами" "HTTPS"
            developer -> spa "Выполнение задач" "HTTPS"
            tester -> spa "Тестирование и баг-репорты" "HTTPS"
            stakeholder -> spa "Просмотр отчетов" "HTTPS"
            admin -> mobile "Управление с мобильных устройств" "HTTPS"
            developer -> mobile "Обновление статусов с телефона" "HTTPS"
        }
    }

    views {
        systemContext pms "SystemContext" {
            include *
            autolayout lr
            title "System Context: Enterprise Project Management Platform"
        }

        container pms "ContainerView" {
            include *
            autolayout lr
            title "Container Diagram: Microservices Architecture"
        }

        dynamic pms "TaskFlow" "Complete flow of creating and assigning a task with notifications" {
            title "Создание задачи: от UI до уведомлений"
            
            projectManager -> pms.spa "Открывает интерфейс" "HTTPS"
            pms.spa -> pms.gateway "GET /api/projects" "HTTPS/WSS"
            pms.gateway -> pms.projectService "getUserProjects()" "gRPC"
            pms.projectService -> pms.postgresProjects "SELECT projects" "JDBC"
            
            pms.spa -> pms.gateway "GET /api/users?role=developer" "HTTPS/WSS"
            pms.gateway -> pms.userService "getUsersByRole()" "gRPC"
            pms.userService -> pms.postgresUsers "SELECT users" "JDBC"
            pms.userService -> pms.redisCache "cache projects" "Redis"
            
            pms.spa -> pms.gateway "POST /api/tasks" "HTTPS/WSS"
            pms.gateway -> pms.taskService "createTask()" "gRPC"
            pms.taskService -> pms.postgresTasks "INSERT task" "JDBC"
            pms.taskService -> pms.elastic "INDEX task" "REST"
            
            pms.taskService -> pms.kafka "publish TaskCreated" "Kafka API"
            pms.kafka -> pms.activityService "consume TaskCreated" "Kafka API"
            pms.activityService -> pms.mongoActivity "log activity" "MongoDB"
            
            pms.kafka -> pms.integrationService "consume TaskCreated" "Kafka API"
            pms.activityService -> emailGateway "send email" "SMTP"
            
            pms.spa -> pms.gateway "GET /api/tasks?websocket" "HTTPS/WSS"
            pms.gateway -> pms.taskService "subscribeToUpdates()" "gRPC"
            pms.taskService -> pms.postgresTasks "real-time status update in DB" "JDBC"
            pms.taskService -> pms.elastic "update search index" "REST"
            
            autolayout lr
        }


        // styling...
    }

}