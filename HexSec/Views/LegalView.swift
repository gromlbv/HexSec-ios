//
//  UnreleasedNavView 2.swift
//  HexSec
//
//  Created by dmitry lbv on 18.04.2025.
//


//
//  UnreleasedNavView.swift
//  HexSec
//
//  Created by dmitry lbv on 10.04.2025.
//

import SwiftUI

struct LegalView: View {
    var body: some View {
        ScrollView {
            Text("""
            УСЛОВИЯ ИСПОЛЬЗОВАНИЯ HEXSEC

            1. Принятие условий
            Использование приложения HexSec означает ваше согласие с настоящими условиями. Если вы не согласны - прекратите использование.

            2. Сбор данных
            Мы храним:
            - Вашу электронную почту
            - Пароли в зашифрованном виде
            - Данные мониторинга доменов
            - Отзывы и диагностические данные

            3. Безопасность
            Все данные передаются по HTTPS и хранятся на защищенных серверах. Мы применяем шифрование AES-256 для конфиденциальной информации.

            4. Возрастные ограничения
            Приложение предназначено для пользователей старше 13 лет. Для младших - требуется согласие родителей.

            5. Ответственность
            Мы не несем ответственности за:
            - Прямой/косвенный ущерб
            - Потерю данных
            - Недоступность сервиса

            6. Изменения условий
            Мы можем изменять эти условия. Продолжение использования после изменений означает их принятие.

            7. Контакты
            По вопросам: support@hexsec.ru
            Юр.адрес: [Укажите юридический адрес]
            ИНН/ОГРН: [Реквизиты]

            © 2024 HexSec. Все права защищены.
            """)
            .font(.system(size: 10))
            .foregroundColor(.gray)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(maxHeight: .infinity, alignment: .top)


        }
        .navigationTitle("Условия пользования")
        .navigationTransition(.automatic)
        #if os(iOS)
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
}

#Preview {
    LegalView()
}
